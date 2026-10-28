// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_greenhouse_suppression.dart';

const _tracerName = 'dartastic_otel_libs_greenhouse';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class GreenhouseResult {
  /// Creates a result.
  const GreenhouseResult({
    this.onBehalfOfUserId,
    this.entityKind,
    this.entityId,
    this.candidateId,
    this.applicationId,
    this.applicationStatus,
    this.jobId,
    this.jobStatus,
    this.openingId,
    this.officeId,
    this.departmentId,
    this.sourceName,
    this.currentStage,
    this.rejectionReason,
    this.scorecardOverall,
    this.offerStatus,
    this.rateLimitRemaining,
    this.statusCode,
  });

  /// `On-Behalf-Of` header — Greenhouse requires this id for write
  /// endpoints so attribution lands on the correct recruiter.
  final String? onBehalfOfUserId;

  /// `candidate` / `application` / `job` / `opening` / `offer` /
  /// `scorecard` / `interview` / `prospect` / `user` / `eeoc` /
  /// `referral` / `tag`.
  final String? entityKind;

  final String? entityId;

  final String? candidateId;
  final String? applicationId;

  /// `active` / `hired` / `rejected` / `converted`.
  final String? applicationStatus;

  final String? jobId;

  /// `open` / `closed` / `draft`.
  final String? jobStatus;

  final String? openingId;

  final String? officeId;
  final String? departmentId;

  /// Application source (Outbound Recruiting / LinkedIn / Indeed /
  /// Referral / Company Website / etc).
  final String? sourceName;

  /// Current pipeline stage (`Application Review` / `Phone Screen` /
  /// `Onsite` / `Offer` / etc — job-specific).
  final String? currentStage;

  /// Filled when status is `rejected`.
  final String? rejectionReason;

  /// `definitely_not` / `no` / `mixed` / `yes` / `strong_yes`.
  final String? scorecardOverall;

  /// `draft` / `approval_sent` / `approved` / `sent` / `accepted` /
  /// `rejected` / `deprecated`.
  final String? offerStatus;

  /// `X-RateLimit-Remaining` header.
  final int? rateLimitRemaining;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class GreenhouseCallResult<T> {
  /// Creates a call result.
  const GreenhouseCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final GreenhouseResult? result;
}

/// Wraps a Greenhouse Harvest API call in a CLIENT span. [operation]
/// is one of `candidates.list`, `candidates.create`,
/// `applications.create`, `applications.advance`,
/// `applications.reject`, `jobs.list`, `jobs.create`,
/// `openings.create`, `scorecards.create`, `offers.create`,
/// `offers.send`, `prospects.create`.
Future<T> tracedGreenhouse<T>({
  required String operation,
  required Future<GreenhouseCallResult<T>> Function() invoke,
}) async {
  if (greenhouseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'greenhouse',
    'rpc.method': operation,
    'greenhouse.operation': operation,
  };

  final span = _tracer().startSpan(
    'greenhouse $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.onBehalfOfUserId != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.on_behalf_of.user_id',
          r.result!.onBehalfOfUserId!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.candidateId != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.candidate.id',
          r.result!.candidateId!,
        ));
      }
      if (r.result!.applicationId != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.application.id',
          r.result!.applicationId!,
        ));
      }
      if (r.result!.applicationStatus != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.application.status',
          r.result!.applicationStatus!,
        ));
      }
      if (r.result!.jobId != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.job.id',
          r.result!.jobId!,
        ));
      }
      if (r.result!.jobStatus != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.job.status',
          r.result!.jobStatus!,
        ));
      }
      if (r.result!.openingId != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.opening.id',
          r.result!.openingId!,
        ));
      }
      if (r.result!.officeId != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.office.id',
          r.result!.officeId!,
        ));
      }
      if (r.result!.departmentId != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.department.id',
          r.result!.departmentId!,
        ));
      }
      if (r.result!.sourceName != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.source.name',
          r.result!.sourceName!,
        ));
      }
      if (r.result!.currentStage != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.current.stage',
          r.result!.currentStage!,
        ));
      }
      if (r.result!.rejectionReason != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.rejection.reason',
          r.result!.rejectionReason!,
        ));
      }
      if (r.result!.scorecardOverall != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.scorecard.overall',
          r.result!.scorecardOverall!,
        ));
      }
      if (r.result!.offerStatus != null) {
        extras.add(OTelAPI.attributeString(
          'greenhouse.offer.status',
          r.result!.offerStatus!,
        ));
      }
      if (r.result!.rateLimitRemaining != null) {
        extras.add(OTelAPI.attributeInt(
          'greenhouse.rate_limit.remaining',
          r.result!.rateLimitRemaining!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Greenhouse HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
