import 'package:flutter_test/flutter_test.dart';
import 'package:kajani/features/dashboard/data/models/plan_api_model.dart';

void main() {
  group('PlanApiModel.fromJson', () {
    test('parses all core fields correctly', () {
      final json = {
        '_id': 'plan123',
        'title': 'Test Event',
        'description': 'A test event description here',
        'category': 'social',
        'coverImage': 'https://res.cloudinary.com/test.jpg',
        'location': 'Kathmandu',
        'date': '2026-12-01',
        'time': '10:00',
        'endTime': '12:00',
        'endDate': '2026-12-01',
        'status': 'upcoming',
        'isPublic': true,
        'maxMembers': 10,
        'creator': 'user123',
        'members': ['user123', 'user456'],
        'savedBy': ['user789'],
      };

      final model = PlanApiModel.fromJson(json);

      expect(model.planId, 'plan123');
      expect(model.title, 'Test Event');
      expect(model.category, 'social');
      expect(model.status, 'upcoming');
      expect(model.endDate, '2026-12-01');
      expect(model.endTime, '12:00');
      expect(model.maxMembers, 10);
      expect(model.creatorId, 'user123');
      expect(model.members, ['user123', 'user456']);
      expect(model.savedBy, ['user789']);
    });

    test('parses creator as a populated object', () {
      final json = {
        '_id': 'plan123',
        'title': 'Test Event',
        'description': 'A test event description here',
        'category': 'social',
        'location': 'Kathmandu',
        'date': '2026-12-01',
        'time': '10:00',
        'endTime': '12:00',
        'endDate': '2026-12-01',
        'status': 'upcoming',
        'creator': {'_id': 'user123', 'firstName': 'Sagar'},
      };

      final model = PlanApiModel.fromJson(json);
      expect(model.creatorId, 'user123'); // extracts _id from populated creator
    });

    test('parses members as populated objects into memberDetails', () {
      final json = {
        '_id': 'plan123',
        'title': 'Test Event',
        'description': 'A test event description here',
        'category': 'social',
        'location': 'Kathmandu',
        'date': '2026-12-01',
        'time': '10:00',
        'endTime': '12:00',
        'endDate': '2026-12-01',
        'status': 'upcoming',
        'members': [
          {'_id': 'user123', 'firstName': 'Sagar', 'lastName': 'Lama'},
        ],
      };

      final model = PlanApiModel.fromJson(json);
      expect(model.memberDetails, isNotNull);
      expect(model.memberDetails!.first.firstName, 'Sagar');
    });

    test('toEntity carries fields through', () {
      final json = {
        '_id': 'plan123',
        'title': 'Test Event',
        'description': 'A test event description here',
        'category': 'social',
        'location': 'Kathmandu',
        'date': '2026-12-01',
        'time': '10:00',
        'endTime': '12:00',
        'endDate': '2026-12-01',
        'status': 'upcoming',
      };

      final entity = PlanApiModel.fromJson(json).toEntity();
      expect(entity.planId, 'plan123');
      expect(entity.title, 'Test Event');
    });
  });
}