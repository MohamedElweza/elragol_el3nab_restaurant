abstract class VerifyOtpState {}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpLoading extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  final String message;
  VerifyOtpSuccess(this.message);

}

class VerifyOtpError extends VerifyOtpState {
  final String message;
  VerifyOtpError(this.message);
}
