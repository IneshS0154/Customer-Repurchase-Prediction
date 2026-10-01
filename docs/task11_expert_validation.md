# Task 11 -- Industry Expert Validation

> **STATUS: NOT YET COMPLETED.** No industry expert has been consulted yet, and this section contains **no expert
> feedback**. Everything below is a plan, an interview guide and empty evidence templates. Task 11 must not be presented
> as complete, and no recommendation in Task 12 may cite expert support, until the consultation has taken place and
> documentary evidence (interview summary, meeting minutes, e-mails, meeting screenshots or a completed feedback form)
> is stored in `docs/evidence/` and referenced here.

*Owner: Member D (with the whole team for the consultation itself).*

## 11.1 What the brief requires

At least one industry expert relevant to the domain must give professional feedback on: the **relevance of the
problem**, the **practicality of the recommendations**, **implementation feasibility** and **organisational impact**.
The report must then show **how the feedback changed the final recommendations**.

## 11.2 Who to consult

Any **one** of the following profiles is relevant (in order of preference):

1. A CRM, customer-retention or e-commerce manager at a wholesale or online retail business.
2. A sales or account manager who manages B2B trade customers (the retailer's customers are largely wholesalers).
3. A marketing-analytics or data-science practitioner who has run retention campaigns or A/B tests in retail.

Record the expert's name (or an anonymised title if they prefer), organisation type, role, years of experience, and why
they are relevant. The consultation also needs their consent to be named and quoted.

## 11.3 Why the expert matters to *this* analysis

Several numbers in the analysis are **placeholders** that only someone with industry knowledge can replace. The expert
consultation is the planned source for them:

| Assumption in the analysis | Current placeholder | Where it is used | What it changes |
|---|---|---|---|
| Gross margin on revenue | 30% | Notebooks 03 (A5, C3) and 05; Task 6 break-even | Contact threshold, predicted profit |
| Cost of one retention offer (voucher + handling) | £10 | Same | Contact threshold, break-even uplift |
| Plausible incremental effect of an offer | 10% of expected spend | Same | Contact share ranges from 4% to 82% depending on it (notebook 03, C3) |
| Tolerable control-group size for a pilot | 20–50% | Task 6 | Detectable effect: 6.1 vs 3.9 points |
| Lead time needed before the Q4 peak | Build-up from August / September (notebook 01) | Task 12 timing | Pilot and campaign calendar |
| How B2B customers are contacted today | Unknown | Task 10 actions | Whether e-mail offers or account-manager calls are realistic |

## 11.4 Interview guide (about 30–40 minutes)

Before the meeting, send a two-page summary of the findings (Tasks 3–5 headline results, the Task 6 pilot design and the
Task 10 framework). Ask the questions below and record answers **in the expert's own words**.

**A. Relevance of the problem**
1. How does a business like this currently notice that a trade customer has stopped ordering?
2. Is "no order in the next 90 days" a sensible definition of a lapsed customer in wholesale giftware, or would you use a
   different window?
3. Our data show that the top 10% of customers bring in about 63% of revenue. Does that match your experience, and how is
   that dependence managed in practice?

**B. Practicality of recommendations**
4. What gross margin and what cost per retention offer would be realistic for a UK online gift wholesaler?
5. From your experience, what size of effect does a retention offer typically have on repeat ordering?
6. Would you give high-value, loyal accounts a discount, or a service contact instead?

**C. Implementation feasibility**
7. Could a business of this size keep a randomised control group that receives no offer for 90 days? What share would be
   acceptable?
8. Who would own a weekly at-risk customer list, and how would account managers want to receive it?
9. What data would realistically be available (order system, e-mail platform, campaign history)?

**D. Organisational impact**
10. Which of our recommendations would you prioritise, and which would you drop?
11. What risks or ethical concerns do you see (e.g. discount expectations, fairness to small customers, data protection)?
12. When should Q4 preparation start for a gift wholesaler?

## 11.5 Evidence log *(to be completed)*

| Field | Entry |
|---|---|
| Expert role and relevance | *pending* |
| Organisation type | *pending* |
| Date of consultation | *pending* |
| Method (in person / video call / e-mail / feedback form) | *pending* |
| Team members present | *pending* |
| Consent to be named / quoted | *pending* |
| Evidence file(s) in `docs/evidence/` | *pending* |

## 11.6 Findings *(to be completed from the evidence)*

| Area | Expert's feedback (summarised, with quotes) | Practical constraint identified |
|---|---|---|
| Relevance of the problem | *pending* | *pending* |
| Practicality of recommendations | *pending* | *pending* |
| Implementation feasibility | *pending* | *pending* |
| Organisational impact | *pending* | *pending* |

## 11.7 How the feedback changed the recommendations *(to be completed)*

| Recommendation (Task 12 ID) | Before the consultation | After the consultation | Reason |
|---|---|---|---|
| *pending* | | | |

After the consultation: replace the placeholders in 11.3 with the expert's figures, rerun notebooks 03 and 05 (section
C3 and the decision rule) with those values, update the Task 6 break-even, and fill in the "Expert feedback" column
of the Task 12 recommendation table.

## 11.8 Completion checklist

- [ ] Expert identified and agrees to participate (and to be named or anonymised)
- [ ] Findings summary sent in advance
- [ ] Consultation held; notes or recording taken
- [ ] Evidence saved in `docs/evidence/` (summary, minutes, e-mails, screenshots or feedback form)
- [ ] Evidence log (11.5) and findings (11.6) completed
- [ ] Placeholder assumptions replaced and notebooks 03 and 05 rerun
- [ ] Change log (11.7) completed and Task 12 "Expert feedback" column filled in
- [ ] Status banner at the top of this file removed
