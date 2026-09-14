import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/maintenance_request_model.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/dummy_data/dummy_data.dart';

final maintenanceRequestsProvider =
    StateNotifierProvider<MaintenanceNotifier, List<MaintenanceRequestModel>>((ref) {
  return MaintenanceNotifier();
});

class MaintenanceNotifier extends StateNotifier<List<MaintenanceRequestModel>> {
  MaintenanceNotifier() : super(_generate()) {
    // initial data
  }

  static List<MaintenanceRequestModel> _generate() {
    final now = DateTime.now();
    final titles = [
      'AC not cooling', 'Leaking faucet', 'Broken TV remote', 'Door lock issue',
      'Bathroom light out', 'Wi-Fi not working', 'Shower pressure low',
      'Minibar fridge noise', 'Window seal broken', 'Smoke detector beep',
      'Balcony door stuck', 'Carpet stain', 'Hair dryer broken',
      'Safe not opening', 'Phone line dead', 'Curtain rod loose',
      'Toilet running', 'Power outlet dead', 'Mirror cracked', 'Thermostat error',
    ];
    return List.generate(20, (i) {
      final room = DummyData.rooms[i % DummyData.rooms.length];
      final staff = DummyData.staff.where((s) => s.position == UserRole.maintenance).toList();
      final assigned = i % 3 != 0 && staff.isNotEmpty ? staff[i % staff.length] : null;
      final statuses = MaintenanceStatus.values;
      return MaintenanceRequestModel(
        id: 'maint_${i + 1}',
        roomId: room.id,
        roomNumber: room.roomNumber,
        title: titles[i],
        description: 'Guest reported: ${titles[i]}. Please inspect and resolve.',
        assignedStaffId: assigned?.id,
        assignedStaffName: assigned?.fullName,
        status: statuses[i % statuses.length],
        priority: TaskPriority.values[i % TaskPriority.values.length],
        estimatedCost: 50.0 + i * 15,
        createdAt: now.subtract(Duration(days: i ~/ 2)),
        updatedAt: now.subtract(Duration(hours: i)),
      );
    });
  }

  void updateStatus(String id, MaintenanceStatus status) {
    state = state.map((r) {
      if (r.id == id) {
        return r.copyWith(
          status: status,
          updatedAt: DateTime.now(),
          completedAt: status == MaintenanceStatus.completed ? DateTime.now() : r.completedAt,
        );
      }
      return r;
    }).toList();
  }

  void create(MaintenanceRequestModel request) {
    state = [request, ...state];
  }
}

class MaintenanceDashboardScreen extends ConsumerStatefulWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  ConsumerState<MaintenanceDashboardScreen> createState() => _MaintenanceDashboardScreenState();
}

class _MaintenanceDashboardScreenState extends ConsumerState<MaintenanceDashboardScreen> {
  MaintenanceStatus? _filter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(maintenanceRequestsProvider);

    final pending = requests.where((r) => r.status == MaintenanceStatus.pending).length;
    final inProgress = requests.where((r) => r.status == MaintenanceStatus.inProgress).length;
    final completed = requests.where((r) => r.status == MaintenanceStatus.completed).length;

    var filtered = requests;
    if (_filter != null) filtered = filtered.where((r) => r.status == _filter).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      filtered = filtered.where((r) =>
          r.roomNumber.toLowerCase().contains(q) ||
          r.title.toLowerCase().contains(q) ||
          (r.assignedStaffName ?? '').toLowerCase().contains(q)).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createRequest(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _Kpi('Pending', '$pending', AppColors.warning),
                const SizedBox(width: 8),
                _Kpi('In Progress', '$inProgress', AppColors.info),
                const SizedBox(width: 8),
                _Kpi('Completed', '$completed', AppColors.success),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search requests...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _Chip('All', _filter == null, () => setState(() => _filter = null)),
                ...MaintenanceStatus.values.map((s) => _Chip(
                      s.displayName,
                      _filter == s,
                      () => setState(() => _filter = s),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.build_outlined, size: 64, color: AppColors.mediumGrey),
                        const SizedBox(height: 16),
                        Text('No requests found', style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final r = filtered[index];
                      return _RequestCard(
                        request: r,
                        onStatusChange: (status) {
                          ref.read(maintenanceRequestsProvider.notifier).updateStatus(r.id, status);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Status → ${status.displayName}'), backgroundColor: AppColors.success),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _createRequest(BuildContext context) {
    final titleCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Maintenance Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: 'Room Number')),
            const SizedBox(height: 12),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Issue Title')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty || roomCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              final req = MaintenanceRequestModel(
                id: const Uuid().v4(),
                roomId: 'temp',
                roomNumber: roomCtrl.text.trim(),
                title: titleCtrl.text.trim(),
                description: titleCtrl.text.trim(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              ref.read(maintenanceRequestsProvider.notifier).create(req);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request created'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Kpi(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.secondary.withOpacity(0.2),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final MaintenanceRequestModel request;
  final ValueChanged<MaintenanceStatus> onStatusChange;

  const _RequestCard({required this.request, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(request.title, style: Theme.of(context).textTheme.titleSmall)),
              Text('Room ${request.roomNumber}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          Text(request.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Priority: ${request.priority.displayName}', style: Theme.of(context).textTheme.labelSmall),
              if (request.estimatedCost != null) ...[
                const SizedBox(width: 12),
                Text('Est: \$${request.estimatedCost!.toStringAsFixed(0)}', style: Theme.of(context).textTheme.labelSmall),
              ],
              const Spacer(),
              PopupMenuButton<MaintenanceStatus>(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(request.status.displayName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                onSelected: onStatusChange,
                itemBuilder: (_) => MaintenanceStatus.values
                    .map((s) => PopupMenuItem(value: s, child: Text(s.displayName)))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
