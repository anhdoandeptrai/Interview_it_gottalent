import 'package:get/get.dart';

enum ViewState { idle, busy, error }

abstract class BaseViewModel extends GetxController {
  final Rx<ViewState> _state = ViewState.idle.obs;
  final RxString _errorMessage = ''.obs;

  ViewState get state => _state.value;
  String get errorMessage => _errorMessage.value;
  bool get isBusy => _state.value == ViewState.busy;
  bool get hasError => _state.value == ViewState.error;

  void setState(ViewState newState) {
    _state.value = newState;
  }

  void setError(String message) {
    _errorMessage.value = message;
    _state.value = ViewState.error;
  }

  void clearError() {
    _errorMessage.value = '';
    if (_state.value == ViewState.error) {
      _state.value = ViewState.idle;
    }
  }

  void setBusy() {
    _state.value = ViewState.busy;
  }

  void setIdle() {
    _state.value = ViewState.idle;
  }

  Future<T?> runBusyFuture<T>(Future<T> future, {String? errorMessage}) async {
    setBusy();
    try {
      final result = await future;
      setIdle();
      return result;
    } catch (e) {
      setError(errorMessage ?? e.toString());
      return null;
    }
  }
}
