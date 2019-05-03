

select 'insert into PS_UC_USER_DATA (uc_clc_id, uc_clc_ldap_uid, uc_clc_prefnm, uc_clc_fst_at, created_at, updated_at) values '
|| '(' || id || ','
|| '''' || uid || '''' || ','
|| '''' || coalesce(preferred_name, ' ') || '''' ||  ','
|| 'TO_DATE(' || ''''
|| to_char(first_login_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ', ' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')' || ','
|| 'TO_DATE(' || ''''
|| to_char(created_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')' || ','
|| 'TO_DATE(' || ''''
|| to_char(updated_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')'
|| ');'
from user_data;


select 'insert into PS_UC_RECENT_UIDS (uc_clc_id, uc_clc_oid, uc_clc_stor_id, created_at, updated_at) values '
|| '(' || id || ','
|| '''' || owner_id || '''' || ','
|| '''' || stored_uid || '''' || ','
|| 'TO_DATE(' || ''''
|| to_char(created_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')' || ','
|| 'TO_DATE(' || ''''
|| to_char(updated_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')'
|| ');'
from recent_uids;



select 'insert into PS_UC_SAVED_UIDS (uc_clc_id, uc_clc_oid, uc_clc_stor_id, created_at, updated_at) values '
|| '(' || id || ','
|| '''' || owner_id || '''' || ','
|| '''' || stored_uid || '''' || ','
|| 'TO_DATE(' || ''''
|| to_char(created_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')' || ','
|| 'TO_DATE(' || ''''
|| to_char(updated_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')'
|| ');'
from saved_uids;




select 'insert into PS_UC_USER_AUTHS (uc_clc_id, uc_clc_ldap_uid, uc_clc_is_su, uc_clc_active, uc_clc_is_au, uc_clc_is_vw, created_at, updated_at) values '
|| '(' || id || ','
|| '''' || uid || '''' || ','
|| '''' || case when is_superuser ='t' then '1' when is_superuser ='f' then '0' end || '''' || ','
|| '''' || case when active='t' then '1' when active='f' then '0' end || '''' || ','
|| '''' || case when is_author='t' then '1' when is_author ='f' then '0' end || '''' || ','
|| '''' || case when is_viewer='t' then '1' when is_viewer ='f' then '0' end || '''' || ','
|| 'TO_DATE(' || ''''
|| to_char(created_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')' || ','
|| 'TO_DATE(' || ''''
|| to_char(updated_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')'
|| ');'
from user_auths;





select 'insert into PS_UC_CLC_SRVALERT (uc_clc_id, uc_alrt_pubdt, uc_alrt_snippt, uc_alrt_title, uc_alrt_display, uc_alrt_splash, uc_alrt_body, created_at, updated_at) values '
|| '(' || id || ','
|| 'TO_DATE(' || ''''
|| to_char(publication_date, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')' || ','
|| '''' || case when snippet is null then ' ' when snippet='' then ' ' end || '''' || ','
|| '''' || replace(title, '''', '''''') || '''' || ','
|| '''' || case when display ='t' then '1' when display ='f' then '0' end || '''' || ','
|| '''' || case when splash='t' then '1' when splash='f' then '0' end || '''' || ','
|| '''' || replace(body, '''', '''''') || '''' || ','
|| 'TO_DATE(' || ''''
|| to_char(created_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')' || ','
|| 'TO_DATE(' || ''''
|| to_char(updated_at, 'YYYY-MM-DD HH24:MI:SS')
|| '''' || ',' || '''' || 'RRRR-MM-DD HH24:MI:SS' || '''' || ')'
|| ');'
from service_alerts;




select 'insert into PS_UC_CLC_OAUTH (uc_clc_id, uc_clc_ldap_uid, uc_clc_app_id, access_token, refresh_token, uc_clc_expire, app_data, created_at, updated_at) values '
|| '(' || id || ','
|| '''' || uid || '''' || ','
|| '''' || app_id || '''' || ',' || chr(10)
|| '''' || replace(access_token, '''', '''''') || '''' || ','
|| '''' || replace(refresh_token, '''', '''''') || '''' || ','
|| expiration_time || ','
|| '''' || replace(app_data, '''', '''''') || '''' || ','
|| 'sysdate' || ','
|| 'sysdate'
|| ');'
from oauth2_data;
