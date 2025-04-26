class AppState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? authToken;
  final String? postalId;
  final String? error;

  AppState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.authToken,
    this.postalId,
    this.error,
  });

  AppState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? authToken,
    String? postalId,
    String? error,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authToken: authToken ?? this.authToken,
      postalId: postalId ?? this.postalId,
      error: error ?? this.error,
    );
  }
}