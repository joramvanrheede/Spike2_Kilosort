% Match_multiple_protocols
% Make sure protocols are lined up


ChR2_sessions       = {ChR2_only_data.session_ID};
ArchT_sessions      = {ArchT_only_data.session_ID};
ChR2_ArchT_sessions = {ChR2_ArchT_data.session_ID};

unique_sessions     = unique([ChR2_sessions ArchT_sessions ChR2_ArchT_sessions]);
n_sessions          = length(unique_sessions);

clear matched_ChR2 matched_ArchT matched_ChR2_ArchT
for i = 1:n_sessions
    this_session    = unique_sessions{i};
    
    is_ChR2_session         = strcmp(ChR2_sessions, this_session);
    is_ArchT_session        = strcmp(ArchT_sessions, this_session);
    is_ChR2_ArchT_session   = strcmp(ChR2_ArchT_sessions, this_session);
    
    if any(is_ChR2_session)
        matched_ChR2(i)     	= ChR2_only_data(is_ChR2_session);
    end
    if any(is_ArchT_session)
        matched_ArchT(i)        = ArchT_only_data(is_ArchT_session);
    end
    if any(is_ChR2_ArchT_session)
        matched_ChR2_ArchT(i)   = ChR2_ArchT_data(is_ChR2_ArchT_session);
    end
end
