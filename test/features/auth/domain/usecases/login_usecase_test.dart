import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kajani/core/error/failures.dart';
import 'package:kajani/features/auth/domain/entities/auth_entity.dart';
import 'package:kajani/features/auth/domain/repositories/auth_repository.dart';
import 'package:kajani/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUsecase usecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  const tEmail = 'sagar@gmail.com';
  const tPassword = 'password123';

  const tAuthEntity = AuthEntity(
    authId: '123',
    email: tEmail,
    provider: 'traditional',
  );

  group('LoginUsecase', () {
    test('returns AuthEntity when the repository login succeeds', () async {
      // arrange
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      // act
      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // assert
      expect(result, const Right(tAuthEntity));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns a Failure when the repository login fails', () async {
      // arrange
      const tFailure = ApiFailure(message: 'Invalid credentials');
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });
  });
}