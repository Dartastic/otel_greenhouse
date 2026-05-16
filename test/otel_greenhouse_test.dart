// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_greenhouse/otel_greenhouse.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_greenhouse-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('applications.advance records candidate + stage + source', () async {
    await tracedGreenhouse<String>(
      operation: 'applications.advance',
      invoke: () async => const GreenhouseCallResult(
        value: 'ok',
        result: GreenhouseResult(
          onBehalfOfUserId: 'rec_42',
          candidateId: 'cand_1',
          applicationId: 'app_1',
          applicationStatus: 'active',
          jobId: 'job_1',
          jobStatus: 'open',
          sourceName: 'LinkedIn',
          currentStage: 'Onsite',
          rateLimitRemaining: 195,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('greenhouse applications.advance')!);
    expect(a['greenhouse.on_behalf_of.user_id'], 'rec_42');
    expect(a['greenhouse.application.status'], 'active');
    expect(a['greenhouse.source.name'], 'LinkedIn');
    expect(a['greenhouse.current.stage'], 'Onsite');
    expect(a['greenhouse.rate_limit.remaining'], 195);
  });

  test('rejected application captures reason without span error', () async {
    await tracedGreenhouse<String>(
      operation: 'applications.reject',
      invoke: () async => const GreenhouseCallResult(
        value: 'ok',
        result: GreenhouseResult(
          applicationId: 'app_2',
          applicationStatus: 'rejected',
          rejectionReason: 'Skills not aligned',
        ),
      ),
    );
    final s = spans.findSpanByName('greenhouse applications.reject')!;
    expect(s.status, isNot(SpanStatusCode.Error));
    expect(attrsOf(s)['greenhouse.rejection.reason'], 'Skills not aligned');
  });

  test('offers.create records status + scorecard', () async {
    await tracedGreenhouse<String>(
      operation: 'offers.create',
      invoke: () async => const GreenhouseCallResult(
        value: 'ok',
        result: GreenhouseResult(
          candidateId: 'cand_3',
          scorecardOverall: 'strong_yes',
          offerStatus: 'draft',
          statusCode: 201,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('greenhouse offers.create')!);
    expect(a['greenhouse.scorecard.overall'], 'strong_yes');
    expect(a['greenhouse.offer.status'], 'draft');
  });

  test('HTTP 422 sets span error', () async {
    await tracedGreenhouse<String>(
      operation: 'candidates.create',
      invoke: () async => const GreenhouseCallResult(
        value: 'ok',
        result: GreenhouseResult(statusCode: 422),
      ),
    );
    expect(
      spans.findSpanByName('greenhouse candidates.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutGreenhouseInstrumentationAsync(() async {
      await tracedGreenhouse<String>(
        operation: 'jobs.list',
        invoke: () async => const GreenhouseCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('greenhouse '), isEmpty);
  });
}
