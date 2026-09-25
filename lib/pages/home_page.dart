import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../state/counter_signals.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final EffectCleanup _disposeCounterEffect;

  @override
  void initState() {
    super.initState();
    // Effect mengirim perubahan signal ke Debug Console.
    _disposeCounterEffect = effect(() {
      debugPrint('Counter berubah menjadi: ${counter.value}');
    });
  }

  @override
  void dispose() {
    // Effect dibersihkan ketika halaman ditutup.
    _disposeCounterEffect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Signals Demo'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.hub_outlined, color: colors.primary, size: 36),
                      const SizedBox(height: 10),
                      Text(
                        'Fine-grained Reactive State',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Perubahan state langsung diperbarui oleh Signals.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'COUNTER',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Watch hanya membangun ulang angka ini saat counter berubah.
                      Watch(
                        (context) => Text(
                          '${counter.value}',
                          key: const Key('counterValue'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _RoundActionButton(
                            key: const Key('decrementButton'),
                            icon: Icons.remove,
                            tooltip: 'Kurangi',
                            onPressed: decrementCounter,
                          ),
                          const SizedBox(width: 16),
                          FilledButton.tonalIcon(
                            key: const Key('resetButton'),
                            onPressed: resetCounter,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                          ),
                          const SizedBox(width: 16),
                          _RoundActionButton(
                            key: const Key('incrementButton'),
                            icon: Icons.add,
                            tooltip: 'Tambah',
                            onPressed: incrementCounter,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Divider(),
                      ),
                      const _SectionHeading(
                        icon: Icons.calculate_outlined,
                        title: 'Computed State',
                        subtitle: 'Nilai turunan dari Counter Signal',
                      ),
                      const SizedBox(height: 12),
                      Watch(
                        (context) => _InfoTile(
                          label: 'Double Counter',
                          value: '${doubleCounter.value}',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SectionHeading(
                        icon: Icons.bolt_outlined,
                        title: 'Reactive Status',
                        subtitle: 'Kondisi yang dihitung secara otomatis',
                      ),
                      const SizedBox(height: 12),
                      Watch(
                        (context) => _InfoTile(
                          label: 'Status',
                          value: counterStatus.value,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _ConceptFlow(colors: colors),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    onPressed: onPressed,
    icon: Icon(icon),
    tooltip: tooltip,
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              key: Key(
                label == 'Double Counter'
                    ? 'doubleCounterValue'
                    : 'statusValue',
              ),
              textAlign: TextAlign.end,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptFlow extends StatelessWidget {
  const _ConceptFlow({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text(
          'Alur Signals',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Signal  →  Computed  →  UI',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Signal  →  Effect  →  Debug Console',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
