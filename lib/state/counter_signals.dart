import 'package:signals/signals.dart';

// Signal menyimpan state counter.
final counter = signal(0);
// Computed menghasilkan state berdasarkan counter.
final doubleCounter = computed(() => counter.value * 2);
final counterStatus = computed(() {
  if (counter.value == 0) return 'Counter masih 0';
  return counter.value > 0 ? 'Counter bertambah' : 'Counter berkurang';
});
void incrementCounter() => counter.value++;
void decrementCounter() => counter.value--;
void resetCounter() => counter.value = 0;
