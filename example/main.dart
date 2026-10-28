// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_greenhouse/otel_greenhouse.dart';

/// Traces Greenhouse Harvest calls with OpenTelemetry.
///
/// `otel_greenhouse` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Greenhouse Harvest call in
/// [tracedGreenhouse]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'greenhouse-example');

  // Wraps a Greenhouse Harvest API call in a CLIENT span.
  final greenhouseId = await tracedGreenhouse<String>(
    operation: 'candidates.create',
    invoke: () async {
      // Make the Greenhouse Harvest call here, then report what it returned.
      const id = 'greenhouse_8f3a2c';
      return const GreenhouseCallResult(
          value: id,
          result: GreenhouseResult(
              onBehalfOfUserId: 'onbehalfofuser_8f3a2c',
              entityKind: 'candidate',
              entityId: 'entity_8f3a2c',
              candidateId: 'candidate_8f3a2c',
              applicationId: 'application_8f3a2c',
              applicationStatus: 'active',
              jobId: 'job_8f3a2c',
              jobStatus: 'open',
              openingId: 'opening_8f3a2c',
              officeId: 'office_8f3a2c',
              departmentId: 'department_8f3a2c',
              sourceName: 'example',
              currentStage: 'Onsite',
              rejectionReason: 'rejected',
              scorecardOverall: 'definitely_not',
              offerStatus: 'draft',
              rateLimitRemaining: 25,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedGreenhouse candidates.create returned $greenhouseId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutGreenhouseInstrumentationAsync.
  await runWithoutGreenhouseInstrumentationAsync(
    () => tracedGreenhouse<String>(
      operation: 'candidates.create',
      invoke: () async {
        const id = 'greenhouse_8f3a2c';
        return const GreenhouseCallResult(
            value: id,
            result: GreenhouseResult(
                onBehalfOfUserId: 'onbehalfofuser_8f3a2c',
                entityKind: 'candidate',
                entityId: 'entity_8f3a2c',
                candidateId: 'candidate_8f3a2c',
                applicationId: 'application_8f3a2c',
                applicationStatus: 'active',
                jobId: 'job_8f3a2c',
                jobStatus: 'open',
                openingId: 'opening_8f3a2c',
                officeId: 'office_8f3a2c',
                departmentId: 'department_8f3a2c',
                sourceName: 'example',
                currentStage: 'Onsite',
                rejectionReason: 'rejected',
                scorecardOverall: 'definitely_not',
                offerStatus: 'draft',
                rateLimitRemaining: 25,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
