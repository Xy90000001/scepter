# Launch Checklist Template

> Pre-launch gate. Every item must be ✅ before public launch.

---

## Product
- [ ] Core user journey works end-to-end
- [ ] All P0 user stories accepted
- [ ] Edge cases handled (empty states, errors, limits)
- [ ] Mobile/responsive tested
- [ ] Accessibility baseline (WCAG AA)

---

## Engineering
- [ ] Tests pass (unit + integration + e2e)
- [ ] Type checking / linting clean
- [ ] Secrets scanned (no keys in code)
- [ ] Dependencies audited (no critical CVEs)
- [ ] Deploy script tested on staging
- [ ] Rollback plan documented
- [ ] Monitoring/alerting configured
- [ ] Logs structured & queryable
- [ ] Error tracking (Sentry/similar) wired
- [ ] Performance baseline measured

---

## Security
- [ ] AuthZ on all endpoints
- [ ] Input validation / sanitization
- [ ] Rate limiting on public endpoints
- [ ] HTTPS everywhere, HSTS
- [ ] CSP headers
- [ ] Data encryption at rest / in transit
- [ ] Backup / restore tested

---

## Payments & Legal
- [ ] Stripe/webhook tested (success, failure, retry)
- [ ] Refund/cancellation flow works
- [ ] Terms of Service / Privacy Policy published
- [ ] GDPR/CCPA compliance (if applicable)
- [ ] Invoice generation works

---

## Analytics & Growth
- [ ] Event tracking for core funnel
- [ ] Conversion funnels defined in GA/Posthog/Mixpanel
- [ ] UTM strategy for all channels
- [ ] Referral/affiliate tracking (if applicable)
- [ ] Email sequences (welcome, activation, retention) drafted

---

## Support & Ops
- [ ] Help docs / FAQ for top 10 questions
- [ ] Support inbox / chat widget configured
- [ ] On-call rotation defined
- [ ] Runbook for top 5 failure scenarios
- [ ] Status page configured

---

## Launch Day
- [ ] DNS / SSL verified
- [ ] Feature flags: launch features ON
- [ ] Monitoring dashboard open
- [ ] Team in war room / on call
- [ ] Rollback button tested
- [ ] Communication drafts ready (tweet, email, Product Hunt, etc.)

---

## Post-Launch (Week 1)
- [ ] Daily metrics review
- [ ] Support ticket triage
- [ ] Bug bash / fix critical issues
- [ ] User feedback collection
- [ ] Retrospective scheduled

---

*Product: {{PROJECT}} | Launch Target: {{DATE}} | Go/No-Go Meeting: {{DATE}}*