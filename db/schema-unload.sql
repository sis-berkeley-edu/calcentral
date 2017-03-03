--
-- PostgreSQL database schema clean
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP INDEX public.index_user_auths_on_uid;
DROP INDEX public.index_summer_sub_terms_on_year_and_sub_term_code;
DROP INDEX public.index_service_alerts_on_display_and_created_at;
DROP INDEX public.index_canvas_site_mailing_lists_on_canvas_site_id;
DROP INDEX public.mailing_list_membership_index;
ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_pkey;
ALTER TABLE ONLY public.user_auths DROP CONSTRAINT user_auths_pkey;
ALTER TABLE ONLY public.summer_sub_terms DROP CONSTRAINT summer_sub_terms_pkey;
ALTER TABLE ONLY public.service_alerts DROP CONSTRAINT service_alerts_pkey;
DROP INDEX public.index_oec_course_codes_on_dept_name_and_catalog_id;
DROP INDEX public.index_oec_course_codes_on_dept_code;
ALTER TABLE ONLY public.oec_course_codes DROP CONSTRAINT oec_course_codes_pkey;
ALTER TABLE ONLY public.links DROP CONSTRAINT links_pkey;
ALTER TABLE ONLY public.link_sections DROP CONSTRAINT link_sections_pkey;
ALTER TABLE ONLY public.link_categories DROP CONSTRAINT link_categories_pkey;
ALTER TABLE ONLY public.canvas_site_mailing_lists DROP CONSTRAINT canvas_site_mailing_lists_pkey;
ALTER TABLE ONLY public.canvas_site_mailing_list_members DROP CONSTRAINT canvas_site_mailing_list_members_pkey;
ALTER TABLE public.user_roles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.user_auths ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.summer_sub_terms ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.service_alerts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.oec_course_codes ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.links ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.link_sections ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.link_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.canvas_site_mailing_lists ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.canvas_site_mailing_list_members ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.user_roles_id_seq;
DROP TABLE public.user_roles;
DROP SEQUENCE public.user_auths_id_seq;
DROP TABLE public.user_auths;
DROP SEQUENCE public.summer_sub_terms_id_seq;
DROP TABLE public.summer_sub_terms;
DROP SEQUENCE public.service_alerts_id_seq;
DROP TABLE public.service_alerts;
DROP SEQUENCE public.oec_course_codes_id_seq;
DROP TABLE public.oec_course_codes;
DROP TABLE public.links_user_roles;
DROP SEQUENCE public.links_id_seq;
DROP TABLE public.links;
DROP TABLE public.link_sections_links;
DROP SEQUENCE public.link_sections_id_seq;
DROP TABLE public.link_sections;
DROP TABLE public.link_categories_link_sections;
DROP SEQUENCE public.link_categories_id_seq;
DROP TABLE public.link_categories;
DROP SEQUENCE public.canvas_site_mailing_lists_id_seq;
DROP TABLE public.canvas_site_mailing_lists;
DROP SEQUENCE public.canvas_site_mailing_list_members_id_seq;
DROP TABLE public.canvas_site_mailing_list_members;

DROP TABLE public.canvas_synchronization;
DROP TABLE public.notifications;
DROP TABLE public.oauth2_data;
DROP TABLE public.recent_uids;
DROP TABLE public.saved_uids;
DROP TABLE public.schema_migrations;
DROP TABLE public.schema_migrations_backup;
DROP TABLE public.schema_migrations_fixed_backup;
DROP TABLE public.user_data;
DROP TABLE public.user_visits;
DROP TABLE public.webcast_course_site_log;
