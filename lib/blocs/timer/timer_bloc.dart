import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_demo/blocs/timer/timer_event.dart';
import 'package:kanban_demo/blocs/timer/timer_state.dart';

// TimerBloc Definition
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Duration _elapsedTime = Duration.zero;
  late final DateTime _startTime;
  Timer? _timer;

  TimerBloc() : super(TimerInitial()) {
    on<StartTimerEvent>(_onStartTimer);  // Handle StartTimerEvent
    on<StopTimerEvent>(_onStopTimer);    // Handle StopTimerEvent
    on<ResetTimerEvent>(_onResetTimer);  // Handle ResetTimerEvent
  }

  // Event handlers
  Future<void> _onStartTimer(StartTimerEvent event, Emitter<TimerState> emit) async {
  // Get the current time
  DateTime currentTime = DateTime.now();

  // Calculate the start time by subtracting the initialElapsedTime from current time
  _startTime = currentTime.subtract(event.initialElapsedTime); // Using initialElapsedTime

  // Start the timer if it's not already running
  if (_timer == null || !_timer!.isActive) {
    _startTimer(); // Start the timer
  }

  // Emit the state with the calculated elapsed time
  emit(TimerRunning(event.initialElapsedTime));  // Emit the TimerRunning state
}

  Future<void> _onStopTimer(StopTimerEvent event, Emitter<TimerState> emit) async {
    _stopTimer();
    emit(TimerStopped(_elapsedTime));  // Emit TimerStopped as state
  }

  Future<void> _onResetTimer(ResetTimerEvent event, Emitter<TimerState> emit) async {
    _resetTimer();
    emit(TimerInitial());  // Emit TimerInitial as state
  }

  // This is the method to start the timer and update the elapsed time
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Calculate the elapsed time based on the start time
      final elapsedTime = DateTime.now().difference(_startTime);

      // Emit the updated TimerRunning state with the new elapsed time
      // We do not call `add()` here because we're emitting states, not events
      emit(TimerRunning(elapsedTime));  // Emit the updated TimerRunning state
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null; // Clear the timer when stopping it
  }

  void _resetTimer() {
    _elapsedTime = Duration.zero;
    _timer?.cancel();
    _timer = null; // Clear the timer when resetting
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
