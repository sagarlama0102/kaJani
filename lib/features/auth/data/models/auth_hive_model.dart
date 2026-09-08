import 'package:hive/hive.dart';
import 'package:kajani/core/constants/hive_table_constants.dart';
import 'package:kajani/features/auth/domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstants.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String? provider;

  AuthHiveModel({
    this.authId,
    required this.email,
    this.provider,
  });

  // Initial empty constructor for Hive
    AuthHiveModel.initial()
      : authId = '',
        email = '',
        provider = '';

  //from Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      email: entity.email,
      provider: entity.provider,
    );
  }
  //to entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      email: email,
      provider: provider,
    );
  }

  //to entity list
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
