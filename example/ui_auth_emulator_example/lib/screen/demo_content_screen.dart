import 'package:material_ui/material_ui.dart';

import '../theme/example_theme.dart';

/// A typical app screen made of plain material widgets (app bar, cards,
/// fields, buttons, chips, switches, navigation bar), to compare the auth
/// screens with the rest of an app in the same theme (its app bar has the
/// theme actions).
class DemoContentScreen extends StatefulWidget {
  /// Demo content screen.
  const DemoContentScreen({super.key});

  @override
  State<DemoContentScreen> createState() => _DemoContentScreenState();
}

class _DemoContentScreenState extends State<DemoContentScreen> {
  var _period = 'week';
  var _notifications = true;
  var _offline = false;
  final _filters = <String>{'Music'};
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var scheme = theme.colorScheme;
    var textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo app'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {},
          ),
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_none),
            ),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
          const ExampleThemeActions(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New event',
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          setState(() {
            _tab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          Text('Good morning, Camille', style: textTheme.headlineSmall),
          Text(
            'Your week at a glance',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: const Text('CM'),
              ),
              title: const Text('Camille Martin'),
              subtitle: const Text(
                'camille.martin@example.com',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Chip(label: Text('Pro')),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '12',
                  label: 'Events',
                  color: scheme.primaryContainer,
                  onColor: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  value: '48',
                  label: 'Tickets',
                  color: scheme.secondaryContainer,
                  onColor: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  value: '5',
                  label: 'Venues',
                  color: scheme.tertiaryContainer,
                  onColor: scheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Search events',
              hintText: 'Name, venue or artist',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var filter in ['Music', 'Theatre', 'Food', 'Kids'])
                FilterChip(
                  label: Text(filter),
                  selected: _filters.contains(filter),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filters.add(filter);
                      } else {
                        _filters.remove(filter);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'day', label: Text('Day')),
              ButtonSegment(value: 'week', label: Text('Week')),
              ButtonSegment(value: 'month', label: Text('Month')),
            ],
            selected: {_period},
            onSelectionChanged: (selection) {
              setState(() {
                _period = selection.first;
              });
            },
          ),
          const SizedBox(height: 16),
          Card.outlined(
            child: Column(
              children: [
                for (var (icon, title, time) in const [
                  (Icons.music_note_outlined, 'Opening concert', 'Fri 20:30'),
                  (
                    Icons.theater_comedy_outlined,
                    'Street theatre',
                    'Sat 15:00',
                  ),
                  (Icons.restaurant_outlined, 'Food market', 'Sun 12:00'),
                ])
                  ListTile(
                    leading: Icon(icon),
                    title: Text(title),
                    subtitle: Text(time),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card.filled(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Remind me one hour before'),
                  value: _notifications,
                  onChanged: (value) {
                    setState(() {
                      _notifications = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Available offline'),
                  value: _offline,
                  onChanged: (value) {
                    setState(() {
                      _offline = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Profile completion', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          const LinearProgressIndicator(value: 0.6),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: () {}, child: const Text('Save')),
              FilledButton.tonal(onPressed: () {}, child: const Text('Share')),
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              TextButton(onPressed: () {}, child: const Text('Skip')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color onColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                color: onColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(label, style: textTheme.bodySmall?.copyWith(color: onColor)),
          ],
        ),
      ),
    );
  }
}
