import 'package:flutter_test/flutter_test.dart';
import 'package:kajani/features/dashboard/data/models/plan_api_model.dart';

void main() {
  group('PlanApiModel.fromJson', () {
    test('parses a plan with populated creator and members', () {
      // arrange — backend returns populated objects (getPlanById)
      final json = {
        '_id': 'plan123',
        'title': 'Trek to Shivapuri',
        'description': 'A fun trekking trip for beginners',
        'category': 'outdoor',
        'coverImage': '/uploads/cover.jpg',
        'location': 'Shivapuri, Kathmandu',
        'date': '2026-07-15',
        'time': '06:00',
        'endDate': '2026-07-15',
        'endTime': '14:00',
        'status': 'upcoming',
        'isPublic': true,
        'maxMembers': 10,
        'creator': {
          '_id': 'user1',
          'firstName': 'Sagar',
          'lastName': 'Lama',
          'username': 'sagarlama',
          'profilePicture': '/uploads/pic.jpg',
        },
        'members': [
          {
            '_id': 'user1',
            'firstName': 'Sagar',
            'lastName': 'Lama',
            'username': 'sagarlama',
            'profilePicture': '/uploads/pic.jpg',
          },
          {
            '_id': 'user2',
            'firstName': 'Nimesh',
            'lastName': 'Shrestha',
            'username': 'nimeshstha',
          },
        ],
        'savedBy': [],
      };

      // act
      final model = PlanApiModel.fromJson(json);

      // assert
      expect(model.planId, 'plan123');
      expect(model.title, 'Trek to Shivapuri');
      expect(model.category, 'outdoor');
      expect(model.maxMembers, 10);
      expect(model.endDate, '2026-07-15');
      expect(model.endTime, '14:00');

      // creator object should be flattened to just the id
      expect(model.creatorId, 'user1');

      // members should be extracted as id strings
      expect(model.members, ['user1', 'user2']);

      // memberDetails should hold the full objects
      expect(model.memberDetails!.length, 2);
      expect(model.memberDetails![1].firstName, 'Nimesh');
      expect(model.memberDetails![1].profilePicture, isNull);
    });

    test('parses a plan with unpopulated creator and members (raw IDs)', () {
      // arrange — backend returns raw ObjectId strings (createPlan response)
      final json = {
        '_id': 'plan456',
        'title': 'Yoga session',
        'description': 'Peaceful yoga session inside the valley',
        'category': 'outdoor',
        'location': 'Kirtipur, KTM',
        'date': '2026-07-01',
        'time': '17:33',
        'status': 'upcoming',
        'isPublic': true,
        'creator': 'user9',
        'members': ['user9'],
        'savedBy': ['user9'],
      };

      // act
      final model = PlanApiModel.fromJson(json);

      // assert
      expect(model.creatorId, 'user9');
      expect(model.members, ['user9']);
      expect(model.savedBy, ['user9']);

      // no populated objects → memberDetails should be empty, not crash
      expect(model.memberDetails, isEmpty);

      // optional fields absent → should be null, not throw
      expect(model.coverImage, isNull);
      expect(model.maxMembers, isNull);
      expect(model.endDate, isNull);
      expect(model.endTime, isNull);
    });

    test('toEntity carries every field across', () {
      // arrange
      final json = {
        '_id': 'plan789',
        'title': 'Cafe hopping',
        'description': 'Trying out three cafes in one afternoon',
        'category': 'food',
        'coverImage': '/uploads/cafe.jpg',
        'location': 'Thamel',
        'date': '2026-08-01',
        'time': '10:00',
        'endDate': '2026-08-01',
        'endTime': '13:00',
        'status': 'ongoing',
        'isPublic': false,
        'maxMembers': 5,
        'creator': 'user1',
        'members': ['user1', 'user2'],
        'savedBy': ['user3'],
      };

      // act
      final entity = PlanApiModel.fromJson(json).toEntity();

      // assert
      expect(entity.planId, 'plan789');
      expect(entity.title, 'Cafe hopping');
      expect(entity.status, 'ongoing');
      expect(entity.isPublic, false);
      expect(entity.maxMembers, 5);
      expect(entity.creatorId, 'user1');
      expect(entity.members, ['user1', 'user2']);
      expect(entity.savedBy, ['user3']);
      expect(entity.endDate, '2026-08-01');
      expect(entity.endTime, '13:00');
    });
  });
}