% visualise_synch_examples

protocol_number     = 5;

ChR2_trial          = 10;
ArchT_trial         = 10;
ChR2_ArchT_trial    = 18;


% ChR2
visualise_coupling_diff(matched_ChR2(protocol_number),ChR2_trial)

% ArchT
visualise_coupling_diff(matched_ArchT(protocol_number),ArchT_trial)

% ChR2 + ArchT
visualise_coupling_diff(matched_ChR2_ArchT(protocol_number),ChR2_ArchT_trial)


