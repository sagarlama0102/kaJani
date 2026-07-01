import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/api/api_client.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/features/dashboard/data/models/plan_api_model.dart';

final planRemoteDatasourceProvider = Provider<PlanRemoteDatasource>((ref) {
  return PlanRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});

class PlanRemoteDatasource {
  final ApiClient _apiClient;

  PlanRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;


  Future<List<PlanApiModel>> getAllPlans({
    int? page,
    int? size,
    String? search,
    String? category,
    String? status,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.getAllPlans,
      queryParameters: {
        if (page != null) 'page': page,
        if (size != null) 'size': size,
        if (search != null) 'search': search,
        if (category != null) 'category': category,
        if (status != null) 'status': status,
      },
    );

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => PlanApiModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch plans');
  }

  // ─── Get Plan By ID ──────────────────────────────────────────────
  Future<PlanApiModel> getPlanById(String planId) async {
    final response = await _apiClient.get('${ApiEndpoints.getAllPlans}/$planId');

    if (response.data['success'] == true) {
      return PlanApiModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch plan');
  }

  // ─── Create Plan ─────────────────────────────────────────────────
  Future<PlanApiModel> createPlan({
    required String title,
    required String description,
    required String category,
    required String location,
    required String date,
    required String time,
    required String endTime,
    required String endDate,
    bool isPublic = true,
    int? maxMembers,
    String? coverImage,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.getAllPlans,
      data: {
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'date': date,
        'time': time,
        'endTime': endTime,
        'endDate': endDate,
        'isPublic': isPublic,
        if (maxMembers != null) 'maxMembers': maxMembers,
        if (coverImage != null) 'coverImage': coverImage,
      },
    );

    if (response.data['success'] == true) {
      return PlanApiModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to create plan');
  }

  // ─── Update Plan ─────────────────────────────────────────────────
  Future<PlanApiModel> updatePlan(
    String planId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.getAllPlans}/$planId',
      data: data,
    );

    if (response.data['success'] == true) {
      return PlanApiModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update plan');
  }

  // ─── Delete Plan ─────────────────────────────────────────────────
  Future<bool> deletePlan(String planId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.getAllPlans}/$planId',
    );

    if (response.data['success'] == true) return true;
    throw Exception(response.data['message'] ?? 'Failed to delete plan');
  }

  // ─── Get My Plans ────────────────────────────────────────────────
  Future<List<PlanApiModel>> getMyPlans() async {
    final response = await _apiClient.get(ApiEndpoints.myPlans);

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => PlanApiModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch my plans');
  }

  // ─── Get Joined Plans ────────────────────────────────────────────
  Future<List<PlanApiModel>> getJoinedPlans() async {
    final response = await _apiClient.get(ApiEndpoints.joinedPlans);

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => PlanApiModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch joined plans');
  }

  // ─── Get Saved Plans ─────────────────────────────────────────────
  Future<List<PlanApiModel>> getSavedPlans() async {
    final response = await _apiClient.get(ApiEndpoints.savedPlans);

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => PlanApiModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch saved plans');
  }

  // ─── Join Plan ───────────────────────────────────────────────────
  Future<PlanApiModel> joinPlan(String planId) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.getAllPlans}/$planId/join',
    );

    if (response.data['success'] == true) {
      return PlanApiModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to join plan');
  }

  // ─── Leave Plan ──────────────────────────────────────────────────
  Future<PlanApiModel> leavePlan(String planId) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.getAllPlans}/$planId/leave',
    );

    if (response.data['success'] == true) {
      return PlanApiModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to leave plan');
  }

  // ─── Toggle Save Plan ────────────────────────────────────────────
  Future<bool> toggleSavePlan(String planId) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.getAllPlans}/$planId/save',
    );

    if (response.data['success'] == true) {
      return response.data['data']['saved'] as bool;
    }
    throw Exception(response.data['message'] ?? 'Failed to save plan');
  }

  Future<String> uploadCoverImage(File image) async {
  final fileName = image.path.split('/').last;
  final formData = FormData.fromMap({
    'coverImage': await MultipartFile.fromFile(
      image.path,
      filename: fileName,
    ),
  });

  final response = await _apiClient.uploadFile(
    ApiEndpoints.uploadPlanCover,
    formData: formData,
  );

  if (response.data['success'] == true) {
    return response.data['data']['coverImage'] as String;
  }
  throw Exception(response.data['message'] ?? 'Failed to upload image');
}
}