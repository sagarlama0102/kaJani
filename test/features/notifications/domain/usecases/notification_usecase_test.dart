import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kajani/features/notification/domain/entities/notification_entity.dart';
import 'package:kajani/features/notification/domain/repositories/notification_repository.dart';
import 'package:kajani/features/notification/domain/usecases/get_notification_usecase.dart';
import 'package:kajani/features/notification/domain/usecases/get_unread_count_usecase.dart';
import 'package:kajani/features/notification/domain/usecases/mark_all_read_usecase.dart';
import 'package:kajani/features/notification/domain/usecases/mark_as_read_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kajani/core/error/failures.dart';


class MockNotificationRepository extends Mock
    implements INotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  final tNotification = NotificationEntity(
    id: 'notif1',
    recipientId: 'user1',
    senderFirstName: 'Nimesh',
    senderLastName: 'Shrestha',
    type: 'plan_joined',
    planId: 'plan123',
    planTitle: 'Trek to Shivapuri',
    message: 'Nimesh Shrestha joined your plan "Trek to Shivapuri"',
    isRead: false,
    createdAt: DateTime(2026, 7, 2),
  );

  group('GetNotificationsUsecase', () {
    test('returns the list of notifications', () async {
      // arrange
      final usecase = GetNotificationsUsecase(repository: mockRepository);
      when(() => mockRepository.getNotifications())
          .thenAnswer((_) async => Right([tNotification]));

      // act
      final result = await usecase();

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected notifications'),
        (notifications) {
          expect(notifications.length, 1);
          expect(notifications.first.isRead, false);
          expect(notifications.first.planId, 'plan123');
        },
      );
      verify(() => mockRepository.getNotifications()).called(1);
    });

    test('returns an empty list when there are no notifications', () async {
      // arrange
      final usecase = GetNotificationsUsecase(repository: mockRepository);
      when(() => mockRepository.getNotifications())
          .thenAnswer((_) async => const Right(<NotificationEntity>[]));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right(<NotificationEntity>[]));
    });

    test('passes a failure through when the fetch fails', () async {
      // arrange
      final usecase = GetNotificationsUsecase(repository: mockRepository);
      const tFailure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.getNotifications())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase();

      // assert
      result.fold(
        (failure) => expect(failure.message, 'No internet connection'),
        (_) => fail('expected a failure'),
      );
    });
  });

  group('MarkAsReadUsecase', () {
    test('calls the repository with the right notification id', () async {
      // arrange
      final usecase = MarkAsReadUsecase(repository: mockRepository);
      when(() => mockRepository.markAsRead(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result =
          await usecase(const MarkAsReadParams(notificationId: 'notif1'));

      // assert
      expect(result.isRight(), true);
      verify(() => mockRepository.markAsRead('notif1')).called(1);
    });
  });

  group('MarkAllReadUsecase', () {
    test('calls the repository once', () async {
      // arrange
      final usecase = MarkAllReadUsecase(repository: mockRepository);
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase();

      // assert
      expect(result.isRight(), true);
      verify(() => mockRepository.markAllAsRead()).called(1);
    });
  });

  group('GetUnreadCountUsecase', () {
    test('returns the unread count', () async {
      // arrange
      final usecase = GetUnreadCountUsecase(repository: mockRepository);
      when(() => mockRepository.getUnreadCount())
          .thenAnswer((_) async => const Right(3));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right(3));
    });

    test('returns zero when everything has been read', () async {
      // arrange
      final usecase = GetUnreadCountUsecase(repository: mockRepository);
      when(() => mockRepository.getUnreadCount())
          .thenAnswer((_) async => const Right(0));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right(0));
    });
  });
}