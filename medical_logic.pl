% ================================
%   SMART MEDICAL DIAGNOSIS SYSTEM
% ================================

% ---------- Allow flexible definitions ----------
:- discontiguous treatment/2.
:- discontiguous risk_level/2.

% ---------- Symptoms Database ----------

symptom_of(flu, fever).
symptom_of(flu, cough).
symptom_of(flu, fatigue).
symptom_of(flu, body_ache).

symptom_of(common_cold, sneezing).
symptom_of(common_cold, sore_throat).
symptom_of(common_cold, runny_nose).

symptom_of(malaria, high_fever).
symptom_of(malaria, chills).
symptom_of(malaria, sweating).
symptom_of(malaria, nausea).

symptom_of(dengue, high_fever).
symptom_of(dengue, severe_headache).
symptom_of(dengue, joint_pain).
symptom_of(dengue, skin_rash).

symptom_of(covid_19, fever).
symptom_of(covid_19, dry_cough).
symptom_of(covid_19, shortness_of_breath).
symptom_of(covid_19, loss_of_taste).

symptom_of(tuberculosis, persistent_cough).
symptom_of(tuberculosis, coughing_blood).
symptom_of(tuberculosis, weight_loss).
symptom_of(tuberculosis, night_sweats).

symptom_of(heatstroke, high_body_temp).
symptom_of(heatstroke, altered_mental_state).
symptom_of(heatstroke, rapid_breathing).

symptom_of(hypothermia, shivering).
symptom_of(hypothermia, confusion).
symptom_of(hypothermia, slow_breathing).

symptom_of(diabetes_type_2, frequent_urination).
symptom_of(diabetes_type_2, increased_thirst).
symptom_of(diabetes_type_2, fatigue).
symptom_of(diabetes_type_2, blurred_vision).

symptom_of(hypertension, severe_headache).
symptom_of(hypertension, chest_pain).
symptom_of(hypertension, shortness_of_breath).
symptom_of(typhoid, prolonged_fever).
symptom_of(typhoid, stomach_pain).
symptom_of(typhoid, weakness).
symptom_of(typhoid, headache).


% ---------- Treatments ----------

treatment(flu, 'Rest, hydration, antiviral medication').
treatment(common_cold, 'Warm fluids, rest').
treatment(malaria, 'Immediate antimalarial drugs').
treatment(dengue, 'Fluid therapy and platelet monitoring').
treatment(covid_19, 'Isolation and oxygen support').
treatment(tuberculosis, 'Long-term antibiotics').
treatment(typhoid, 'Antibiotics and fluid therapy').
treatment(heatstroke, 'Immediate cooling and IV fluids').
treatment(hypothermia, 'Gradual warming treatment').
treatment(diabetes_type_2, 'Insulin, diet control').
treatment(hypertension, 'BP control medication').


% ---------- Risk Levels ----------

risk_level(flu, moderate).
risk_level(common_cold, low).
risk_level(malaria, high).
risk_level(dengue, high).
risk_level(covid_19, high).
risk_level(typhoid, high).
risk_level(tuberculosis, high).
risk_level(heatstroke, critical).
risk_level(hypothermia, critical).
risk_level(diabetes_type_2, moderate).
risk_level(hypertension, moderate).


% ---------- Utility Predicates ----------

get_symptoms(Disease, Symptoms) :-
    findall(S, symptom_of(Disease, S), Symptoms).

count_matches([], _, 0).
count_matches([H|T], List, Count) :-
    member(H, List), !,
    count_matches(T, List, Rest),
    Count is Rest + 1.
count_matches([_|T], List, Count) :-
    count_matches(T, List, Count).


% ---------- Diagnosis System ----------

best_diagnosis(PatientSymptoms, BestDisease, BestScore) :-
    setof(D, S^symptom_of(D, S), Diseases),

    findall(Score-Disease,
        (
            member(Disease, Diseases),
            get_symptoms(Disease, DS),
            count_matches(PatientSymptoms, DS, Score),
            Score >= 2
        ),
        Results
    ),

    Results \= [],   % prevent crash if no match
    sort(Results, Sorted),
    reverse(Sorted, [BestScore-BestDisease|_]).


% ---------- Emergency Level ----------

emergency_level(Disease, critical) :-
    risk_level(Disease, critical).

emergency_level(Disease, emergency) :-
    risk_level(Disease, high).

emergency_level(Disease, stable) :-
    risk_level(Disease, moderate).

emergency_level(Disease, safe) :-
    risk_level(Disease, low).


% ---------- Patient Management ----------

% FIXED: correct random function
generate_patient_id(Name, ID) :-
    random_between(1000, 9999, R),
    number_string(R, NumStr),
    string_concat("PAT-", Name, Temp),
    string_concat(Temp, "-", Temp2),
    string_concat(Temp2, NumStr, ID).

:- dynamic patient_record/3.

register_patient(Name, Disease, ID) :-
    generate_patient_id(Name, ID),
    assertz(patient_record(ID, Name, Disease)).

discharge_patient(ID) :-
    retract(patient_record(ID, _, _)).

list_patients :-
    patient_record(ID, Name, Disease),
    write(ID), write(' - '), write(Name), write(' - '), write(Disease), nl,
    fail.
list_patients.