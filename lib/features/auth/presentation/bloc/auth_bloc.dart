// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/services/profile_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthBloc() : super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final role = await ProfileService.getUserRole();
      emit(AuthAuthenticated(user: session.user, role: role));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: event.email.trim(),
        password: event.password,
      );
      if (response.user != null) {
        final role = await ProfileService.getUserRole();
        emit(AuthAuthenticated(user: response.user!, role: role));
      } else {
        emit(const AuthError(message: 'Login failed. Please try again.'));
      }
    } on AuthException catch (e) {
      emit(AuthError(message: _parseAuthError(e.message)));
    } catch (e) {
      emit(const AuthError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final response = await _supabase.auth.signUp(
        email: event.email.trim(),
        password: event.password,
        data: {
          'full_name': event.fullName,
          'phone': event.phone,
        },
      );
      if (response.user != null) {
        emit(const AuthSuccess(
          message: 'Account created! Please check your email to verify your account.',
        ));
      } else {
        emit(const AuthError(message: 'Registration failed. Please try again.'));
      }
    } on AuthException catch (e) {
      emit(AuthError(message: _parseAuthError(e.message)));
    } catch (e) {
      emit(const AuthError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onForgotPassword(
      AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _supabase.auth.resetPasswordForEmail(
        event.email.trim(),
        redirectTo: 'athimart://reset-password',
      );
      emit(const AuthPasswordResetSent());
    } on AuthException catch (e) {
      emit(AuthError(message: _parseAuthError(e.message)));
    } catch (e) {
      emit(const AuthError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _supabase.auth.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError(message: 'Failed to sign out. Please try again.'));
    }
  }

  String _parseAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    } else if (message.contains('User already registered')) {
      return 'An account with this email already exists.';
    } else if (message.contains('Email not confirmed')) {
      return 'Please verify your email before signing in.';
    } else if (message.contains('Password should be at least')) {
      return 'Password must be at least 6 characters long.';
    } else if (message.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return message;
  }
}