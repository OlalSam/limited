--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9
-- Dumped by pg_dump version 16.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: driver_shifts; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.driver_shifts (
    id integer NOT NULL,
    driver_username character varying(50) NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone,
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT driver_shifts_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.driver_shifts OWNER TO olal;

--
-- Name: driver_shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.driver_shifts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.driver_shifts_id_seq OWNER TO olal;

--
-- Name: driver_shifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.driver_shifts_id_seq OWNED BY public.driver_shifts.id;


--
-- Name: financials; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.financials (
    financial_id integer NOT NULL,
    trip_id integer NOT NULL,
    revenue numeric(10,2) NOT NULL,
    expenses numeric(10,2) NOT NULL,
    profit numeric(10,2) NOT NULL
);


ALTER TABLE public.financials OWNER TO olal;

--
-- Name: financials_financial_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.financials_financial_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.financials_financial_id_seq OWNER TO olal;

--
-- Name: financials_financial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.financials_financial_id_seq OWNED BY public.financials.financial_id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    driver_id character varying(50) NOT NULL,
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    accuracy double precision,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.locations OWNER TO olal;

--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locations_id_seq OWNER TO olal;

--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: maintenance; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.maintenance (
    maintenanceid integer NOT NULL,
    vehicleid integer,
    maintenancedate timestamp without time zone,
    maintenancetype character varying(50),
    description text,
    cost double precision,
    status character varying(20)
);


ALTER TABLE public.maintenance OWNER TO olal;

--
-- Name: maintenance_maintenanceid_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.maintenance_maintenanceid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.maintenance_maintenanceid_seq OWNER TO olal;

--
-- Name: maintenance_maintenanceid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.maintenance_maintenanceid_seq OWNED BY public.maintenance.maintenanceid;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    driver_username character varying(50) NOT NULL,
    title character varying(100) NOT NULL,
    message text NOT NULL,
    icon character varying(50),
    color character varying(50),
    created_at timestamp with time zone DEFAULT now(),
    read_at timestamp with time zone
);


ALTER TABLE public.notifications OWNER TO olal;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO olal;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: route_assignments; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.route_assignments (
    id integer NOT NULL,
    vehicle_id integer NOT NULL,
    driver_id integer NOT NULL,
    route_id integer NOT NULL,
    assignment_date date NOT NULL,
    status character varying(20) DEFAULT 'scheduled'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT route_assignments_status_check CHECK (((status)::text = ANY ((ARRAY['scheduled'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.route_assignments OWNER TO olal;

--
-- Name: route_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.route_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.route_assignments_id_seq OWNER TO olal;

--
-- Name: route_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.route_assignments_id_seq OWNED BY public.route_assignments.id;


--
-- Name: route_kpis; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.route_kpis (
    id integer NOT NULL,
    route_id integer NOT NULL,
    metric_at timestamp with time zone NOT NULL,
    headway_target_s integer NOT NULL,
    on_time_perf_pct numeric(5,2) NOT NULL,
    avg_speed_kmh double precision,
    load_factor_pct double precision,
    extra_metrics jsonb,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.route_kpis OWNER TO olal;

--
-- Name: route_kpis_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.route_kpis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.route_kpis_id_seq OWNER TO olal;

--
-- Name: route_kpis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.route_kpis_id_seq OWNED BY public.route_kpis.id;


--
-- Name: route_time_patterns; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.route_time_patterns (
    id integer NOT NULL,
    route_id integer NOT NULL,
    stage character varying(50) NOT NULL,
    time_slot tsrange NOT NULL,
    demand_factor numeric(3,2) DEFAULT 1.00 NOT NULL,
    vehicle_requirement integer
);


ALTER TABLE public.route_time_patterns OWNER TO olal;

--
-- Name: route_time_patterns_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.route_time_patterns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.route_time_patterns_id_seq OWNER TO olal;

--
-- Name: route_time_patterns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.route_time_patterns_id_seq OWNED BY public.route_time_patterns.id;


--
-- Name: route_timetables; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.route_timetables (
    id integer NOT NULL,
    route_id integer NOT NULL,
    service_date date NOT NULL,
    departure_times time without time zone[] NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.route_timetables OWNER TO olal;

--
-- Name: route_timetables_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.route_timetables_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.route_timetables_id_seq OWNER TO olal;

--
-- Name: route_timetables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.route_timetables_id_seq OWNED BY public.route_timetables.id;


--
-- Name: routes; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.routes (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    origin_stage character varying(100) NOT NULL,
    destination_stage character varying(100) NOT NULL,
    stages jsonb NOT NULL,
    operational_hours tsrange DEFAULT tsrange('2000-01-01 05:30:00'::timestamp without time zone, '2000-01-01 22:30:00'::timestamp without time zone, '[)'::text),
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.routes OWNER TO olal;

--
-- Name: routes_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.routes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.routes_id_seq OWNER TO olal;

--
-- Name: routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.routes_id_seq OWNED BY public.routes.id;


--
-- Name: trip_records; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.trip_records (
    id integer NOT NULL,
    driver_username character varying(50) NOT NULL,
    trip_date timestamp with time zone NOT NULL,
    passenger_count integer DEFAULT 0 NOT NULL,
    route_id integer,
    vehicle_id integer,
    status character varying(20) DEFAULT 'completed'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT trip_records_status_check CHECK (((status)::text = ANY ((ARRAY['in_progress'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.trip_records OWNER TO olal;

--
-- Name: trip_records_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.trip_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trip_records_id_seq OWNER TO olal;

--
-- Name: trip_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.trip_records_id_seq OWNED BY public.trip_records.id;


--
-- Name: trips; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.trips (
    trip_id integer NOT NULL,
    driver_id integer NOT NULL,
    fare numeric(10,2) NOT NULL,
    route_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    driver_username character varying(50),
    status character varying(20) DEFAULT 'completed'::character varying,
    vehicle_id integer
);


ALTER TABLE public.trips OWNER TO olal;

--
-- Name: trips_trip_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.trips_trip_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trips_trip_id_seq OWNER TO olal;

--
-- Name: trips_trip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.trips_trip_id_seq OWNED BY public.trips.trip_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    first_name character varying(50),
    second_name character varying(50),
    password text NOT NULL,
    email character varying(100),
    phone_number character varying(20),
    driver_licence character varying(50),
    status character varying(20) DEFAULT 'ACTIVE'::character varying,
    role character varying(20) NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['ADMIN'::character varying, 'DRIVER'::character varying, 'USER'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO olal;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO olal;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vehicle; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.vehicle (
    id integer NOT NULL,
    plate_number character varying(20) NOT NULL,
    vehicle_model character varying(100) NOT NULL,
    owner_national_id character varying(20) NOT NULL,
    capacity integer NOT NULL,
    sacco character varying(100),
    status character varying(20) DEFAULT 'available'::character varying NOT NULL,
    lastmaintainance timestamp without time zone,
    CONSTRAINT vehicle_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT vehicle_status_check CHECK (((status)::text = ANY ((ARRAY['available'::character varying, 'assigned'::character varying])::text[])))
);


ALTER TABLE public.vehicle OWNER TO olal;

--
-- Name: vehicle_assignments; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.vehicle_assignments (
    id integer NOT NULL,
    vehicle_id integer NOT NULL,
    driver_id integer NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    CONSTRAINT vehicle_assignments_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.vehicle_assignments OWNER TO olal;

--
-- Name: vehicle_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.vehicle_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_assignments_id_seq OWNER TO olal;

--
-- Name: vehicle_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.vehicle_assignments_id_seq OWNED BY public.vehicle_assignments.id;


--
-- Name: vehicle_history; Type: TABLE; Schema: public; Owner: olal
--

CREATE TABLE public.vehicle_history (
    id integer NOT NULL,
    driver_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    latitude double precision,
    "timestamp" timestamp without time zone,
    longitude double precision
);


ALTER TABLE public.vehicle_history OWNER TO olal;

--
-- Name: vehicle_history_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.vehicle_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_history_id_seq OWNER TO olal;

--
-- Name: vehicle_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.vehicle_history_id_seq OWNED BY public.vehicle_history.id;


--
-- Name: vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: olal
--

CREATE SEQUENCE public.vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicle_id_seq OWNER TO olal;

--
-- Name: vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: olal
--

ALTER SEQUENCE public.vehicle_id_seq OWNED BY public.vehicle.id;


--
-- Name: driver_shifts id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.driver_shifts ALTER COLUMN id SET DEFAULT nextval('public.driver_shifts_id_seq'::regclass);


--
-- Name: financials financial_id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.financials ALTER COLUMN financial_id SET DEFAULT nextval('public.financials_financial_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: maintenance maintenanceid; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.maintenance ALTER COLUMN maintenanceid SET DEFAULT nextval('public.maintenance_maintenanceid_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: route_assignments id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_assignments ALTER COLUMN id SET DEFAULT nextval('public.route_assignments_id_seq'::regclass);


--
-- Name: route_kpis id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_kpis ALTER COLUMN id SET DEFAULT nextval('public.route_kpis_id_seq'::regclass);


--
-- Name: route_time_patterns id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_time_patterns ALTER COLUMN id SET DEFAULT nextval('public.route_time_patterns_id_seq'::regclass);


--
-- Name: route_timetables id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_timetables ALTER COLUMN id SET DEFAULT nextval('public.route_timetables_id_seq'::regclass);


--
-- Name: routes id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.routes ALTER COLUMN id SET DEFAULT nextval('public.routes_id_seq'::regclass);


--
-- Name: trip_records id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.trip_records ALTER COLUMN id SET DEFAULT nextval('public.trip_records_id_seq'::regclass);


--
-- Name: trips trip_id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.trips ALTER COLUMN trip_id SET DEFAULT nextval('public.trips_trip_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vehicle id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.vehicle ALTER COLUMN id SET DEFAULT nextval('public.vehicle_id_seq'::regclass);


--
-- Name: vehicle_assignments id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.vehicle_assignments ALTER COLUMN id SET DEFAULT nextval('public.vehicle_assignments_id_seq'::regclass);


--
-- Name: vehicle_history id; Type: DEFAULT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.vehicle_history ALTER COLUMN id SET DEFAULT nextval('public.vehicle_history_id_seq'::regclass);


--
-- Data for Name: driver_shifts; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.driver_shifts (id, driver_username, start_time, end_time, status, created_at) FROM stdin;
558	driver1	2025-05-05 07:27:56.386147+03	2025-05-05 16:27:56.386147+03	completed	2025-05-05 13:41:10.759212+03
559	driver1	2025-05-05 15:21:42.531684+03	2025-05-05 22:51:42.531684+03	completed	2025-05-05 13:41:10.759212+03
560	driver1	2025-05-04 06:32:00.529132+03	2025-05-04 15:32:00.529132+03	completed	2025-05-05 13:41:10.759212+03
561	driver1	2025-05-04 15:17:21.11039+03	2025-05-04 22:47:21.11039+03	completed	2025-05-05 13:41:10.759212+03
562	driver1	2025-05-03 15:08:19.358443+03	2025-05-03 22:38:19.358443+03	completed	2025-05-05 13:41:10.759212+03
563	driver1	2025-05-03 15:15:43.770162+03	2025-05-03 22:45:43.770162+03	completed	2025-05-05 13:41:10.759212+03
564	driver1	2025-05-02 15:35:22.381869+03	2025-05-02 23:05:22.381869+03	completed	2025-05-05 13:41:10.759212+03
565	driver1	2025-05-01 15:33:13.987187+03	2025-05-01 23:03:13.987187+03	completed	2025-05-05 13:41:10.759212+03
566	driver1	2025-04-30 05:58:25.775541+03	2025-04-30 14:58:25.775541+03	completed	2025-05-05 13:41:10.759212+03
567	driver1	2025-04-29 05:57:30.795945+03	2025-04-29 14:57:30.795945+03	completed	2025-05-05 13:41:10.759212+03
568	driver1	2025-04-29 15:57:35.669071+03	2025-04-29 23:27:35.669071+03	completed	2025-05-05 13:41:10.759212+03
569	driver1	2025-04-28 15:26:47.564589+03	2025-04-28 22:56:47.564589+03	completed	2025-05-05 13:41:10.759212+03
570	driver1	2025-04-27 15:40:22.637351+03	2025-04-27 23:10:22.637351+03	completed	2025-05-05 13:41:10.759212+03
571	driver1	2025-04-27 05:57:34.068042+03	2025-04-27 14:57:34.068042+03	completed	2025-05-05 13:41:10.759212+03
572	driver1	2025-04-26 07:16:54.379055+03	2025-04-26 16:16:54.379055+03	completed	2025-05-05 13:41:10.759212+03
573	driver1	2025-04-25 15:58:12.446331+03	2025-04-25 23:28:12.446331+03	completed	2025-05-05 13:41:10.759212+03
574	driver1	2025-04-25 07:05:01.230183+03	2025-04-25 16:05:01.230183+03	completed	2025-05-05 13:41:10.759212+03
575	driver1	2025-04-24 05:51:32.921893+03	2025-04-24 14:51:32.921893+03	completed	2025-05-05 13:41:10.759212+03
576	driver1	2025-04-24 07:18:52.821336+03	2025-04-24 16:18:52.821336+03	completed	2025-05-05 13:41:10.759212+03
577	driver1	2025-04-23 06:15:39.238739+03	2025-04-23 15:15:39.238739+03	completed	2025-05-05 13:41:10.759212+03
578	driver1	2025-04-23 15:52:43.140759+03	2025-04-23 23:22:43.140759+03	completed	2025-05-05 13:41:10.759212+03
579	driver1	2025-04-22 15:37:19.542137+03	2025-04-22 23:07:19.542137+03	completed	2025-05-05 13:41:10.759212+03
580	driver1	2025-04-22 15:07:47.148423+03	2025-04-22 22:37:47.148423+03	completed	2025-05-05 13:41:10.759212+03
581	driver1	2025-04-21 06:06:04.075318+03	2025-04-21 15:06:04.075318+03	completed	2025-05-05 13:41:10.759212+03
582	driver1	2025-04-20 05:36:57.647529+03	2025-04-20 14:36:57.647529+03	completed	2025-05-05 13:41:10.759212+03
583	driver1	2025-04-20 15:14:06.970434+03	2025-04-20 22:44:06.970434+03	completed	2025-05-05 13:41:10.759212+03
584	driver1	2025-04-19 07:19:16.177151+03	2025-04-19 16:19:16.177151+03	completed	2025-05-05 13:41:10.759212+03
585	driver1	2025-04-18 15:53:47.790199+03	2025-04-18 23:23:47.790199+03	completed	2025-05-05 13:41:10.759212+03
586	driver1	2025-04-18 05:38:17.994912+03	2025-04-18 14:38:17.994912+03	completed	2025-05-05 13:41:10.759212+03
587	driver1	2025-04-17 15:08:01.764985+03	2025-04-17 22:38:01.764985+03	completed	2025-05-05 13:41:10.759212+03
588	driver1	2025-04-17 15:44:52.683941+03	2025-04-17 23:14:52.683941+03	completed	2025-05-05 13:41:10.759212+03
589	driver1	2025-04-16 15:12:38.575573+03	2025-04-16 22:42:38.575573+03	completed	2025-05-05 13:41:10.759212+03
590	driver1	2025-04-16 15:38:57.399392+03	2025-04-16 23:08:57.399392+03	completed	2025-05-05 13:41:10.759212+03
591	driver1	2025-04-15 06:41:37.791909+03	2025-04-15 15:41:37.791909+03	completed	2025-05-05 13:41:10.759212+03
592	driver1	2025-04-14 15:35:46.378274+03	2025-04-14 23:05:46.378274+03	completed	2025-05-05 13:41:10.759212+03
593	driver1	2025-04-14 15:24:37.407074+03	2025-04-14 22:54:37.407074+03	completed	2025-05-05 13:41:10.759212+03
594	driver1	2025-04-13 07:23:15.347028+03	2025-04-13 16:23:15.347028+03	completed	2025-05-05 13:41:10.759212+03
595	driver1	2025-04-12 15:24:20.66861+03	2025-04-12 22:54:20.66861+03	completed	2025-05-05 13:41:10.759212+03
596	driver1	2025-04-11 15:48:28.317035+03	2025-04-11 23:18:28.317035+03	completed	2025-05-05 13:41:10.759212+03
597	driver1	2025-04-11 15:38:48.372066+03	2025-04-11 23:08:48.372066+03	completed	2025-05-05 13:41:10.759212+03
598	driver1	2025-04-10 05:39:18.399984+03	2025-04-10 14:39:18.399984+03	completed	2025-05-05 13:41:10.759212+03
599	driver1	2025-04-10 06:40:44.461516+03	2025-04-10 15:40:44.461516+03	completed	2025-05-05 13:41:10.759212+03
600	driver1	2025-04-09 15:37:35.373989+03	2025-04-09 23:07:35.373989+03	completed	2025-05-05 13:41:10.759212+03
601	driver1	2025-04-08 06:26:08.654486+03	2025-04-08 15:26:08.654486+03	completed	2025-05-05 13:41:10.759212+03
602	driver1	2025-04-08 15:14:06.265578+03	2025-04-08 22:44:06.265578+03	completed	2025-05-05 13:41:10.759212+03
603	driver1	2025-04-07 15:45:39.00185+03	\N	cancelled	2025-05-05 13:41:10.759212+03
604	driver1	2025-04-07 06:21:09.103732+03	\N	cancelled	2025-05-05 13:41:10.759212+03
605	driver1	2025-04-06 06:47:57.939197+03	2025-04-06 15:47:57.939197+03	completed	2025-05-05 13:41:10.759212+03
606	driver2	2025-05-05 15:25:25.87522+03	2025-05-05 22:55:25.87522+03	completed	2025-05-05 13:41:10.759212+03
607	driver2	2025-05-05 05:42:58.048096+03	2025-05-05 14:42:58.048096+03	completed	2025-05-05 13:41:10.759212+03
608	driver2	2025-05-04 05:37:14.158319+03	2025-05-04 14:37:14.158319+03	completed	2025-05-05 13:41:10.759212+03
609	driver2	2025-05-03 15:46:30.52625+03	\N	cancelled	2025-05-05 13:41:10.759212+03
610	driver2	2025-05-03 15:52:46.055026+03	2025-05-03 23:22:46.055026+03	completed	2025-05-05 13:41:10.759212+03
611	driver2	2025-05-02 06:22:57.432317+03	2025-05-02 15:22:57.432317+03	completed	2025-05-05 13:41:10.759212+03
612	driver2	2025-05-02 07:01:12.48466+03	2025-05-02 16:01:12.48466+03	completed	2025-05-05 13:41:10.759212+03
613	driver2	2025-05-01 15:07:25.041989+03	2025-05-01 22:37:25.041989+03	completed	2025-05-05 13:41:10.759212+03
614	driver2	2025-04-30 06:11:01.482105+03	2025-04-30 15:11:01.482105+03	completed	2025-05-05 13:41:10.759212+03
615	driver2	2025-04-29 15:33:17.41818+03	2025-04-29 23:03:17.41818+03	completed	2025-05-05 13:41:10.759212+03
616	driver2	2025-04-29 15:51:25.860207+03	2025-04-29 23:21:25.860207+03	completed	2025-05-05 13:41:10.759212+03
617	driver2	2025-04-28 05:57:07.85649+03	2025-04-28 14:57:07.85649+03	completed	2025-05-05 13:41:10.759212+03
618	driver2	2025-04-28 15:55:16.061085+03	2025-04-28 23:25:16.061085+03	completed	2025-05-05 13:41:10.759212+03
619	driver2	2025-04-27 15:59:48.214139+03	2025-04-27 23:29:48.214139+03	completed	2025-05-05 13:41:10.759212+03
620	driver2	2025-04-27 07:28:08.005956+03	2025-04-27 16:28:08.005956+03	completed	2025-05-05 13:41:10.759212+03
621	driver2	2025-04-26 06:36:40.199451+03	2025-04-26 15:36:40.199451+03	completed	2025-05-05 13:41:10.759212+03
622	driver2	2025-04-26 06:02:39.990808+03	2025-04-26 15:02:39.990808+03	completed	2025-05-05 13:41:10.759212+03
623	driver2	2025-04-25 06:23:53.865785+03	2025-04-25 15:23:53.865785+03	completed	2025-05-05 13:41:10.759212+03
624	driver2	2025-04-25 15:11:20.872368+03	2025-04-25 22:41:20.872368+03	completed	2025-05-05 13:41:10.759212+03
625	driver2	2025-04-24 15:19:02.16139+03	2025-04-24 22:49:02.16139+03	completed	2025-05-05 13:41:10.759212+03
626	driver2	2025-04-24 15:06:16.648346+03	2025-04-24 22:36:16.648346+03	completed	2025-05-05 13:41:10.759212+03
627	driver2	2025-04-23 05:50:58.868461+03	2025-04-23 14:50:58.868461+03	completed	2025-05-05 13:41:10.759212+03
628	driver2	2025-04-22 07:21:10.855216+03	2025-04-22 16:21:10.855216+03	completed	2025-05-05 13:41:10.759212+03
629	driver2	2025-04-22 15:48:04.952939+03	2025-04-22 23:18:04.952939+03	completed	2025-05-05 13:41:10.759212+03
630	driver2	2025-04-21 06:00:25.361279+03	2025-04-21 15:00:25.361279+03	completed	2025-05-05 13:41:10.759212+03
631	driver2	2025-04-20 15:51:33.19598+03	2025-04-20 23:21:33.19598+03	completed	2025-05-05 13:41:10.759212+03
632	driver2	2025-04-19 15:27:53.690728+03	2025-04-19 22:57:53.690728+03	completed	2025-05-05 13:41:10.759212+03
633	driver2	2025-04-19 15:16:58.312746+03	\N	cancelled	2025-05-05 13:41:10.759212+03
634	driver2	2025-04-18 15:48:16.74977+03	2025-04-18 23:18:16.74977+03	completed	2025-05-05 13:41:10.759212+03
635	driver2	2025-04-18 15:29:14.36755+03	2025-04-18 22:59:14.36755+03	completed	2025-05-05 13:41:10.759212+03
636	driver2	2025-04-17 06:44:27.889698+03	2025-04-17 15:44:27.889698+03	completed	2025-05-05 13:41:10.759212+03
637	driver2	2025-04-17 05:39:40.08248+03	2025-04-17 14:39:40.08248+03	completed	2025-05-05 13:41:10.759212+03
638	driver2	2025-04-16 07:19:39.470989+03	2025-04-16 16:19:39.470989+03	completed	2025-05-05 13:41:10.759212+03
639	driver2	2025-04-15 05:48:11.145009+03	2025-04-15 14:48:11.145009+03	completed	2025-05-05 13:41:10.759212+03
640	driver2	2025-04-14 06:42:05.655493+03	2025-04-14 15:42:05.655493+03	completed	2025-05-05 13:41:10.759212+03
641	driver2	2025-04-13 07:06:17.764919+03	2025-04-13 16:06:17.764919+03	completed	2025-05-05 13:41:10.759212+03
642	driver2	2025-04-13 15:16:54.306614+03	2025-04-13 22:46:54.306614+03	completed	2025-05-05 13:41:10.759212+03
643	driver2	2025-04-12 15:30:27.993614+03	2025-04-12 23:00:27.993614+03	completed	2025-05-05 13:41:10.759212+03
644	driver2	2025-04-11 05:42:43.97689+03	\N	cancelled	2025-05-05 13:41:10.759212+03
645	driver2	2025-04-11 15:47:50.184956+03	\N	cancelled	2025-05-05 13:41:10.759212+03
646	driver2	2025-04-10 15:57:08.578946+03	2025-04-10 23:27:08.578946+03	completed	2025-05-05 13:41:10.759212+03
647	driver2	2025-04-09 06:33:36.697004+03	2025-04-09 15:33:36.697004+03	completed	2025-05-05 13:41:10.759212+03
648	driver2	2025-04-09 15:51:43.532779+03	\N	cancelled	2025-05-05 13:41:10.759212+03
649	driver2	2025-04-08 15:51:12.312343+03	2025-04-08 23:21:12.312343+03	completed	2025-05-05 13:41:10.759212+03
650	driver2	2025-04-07 15:58:06.172442+03	2025-04-07 23:28:06.172442+03	completed	2025-05-05 13:41:10.759212+03
651	driver2	2025-04-06 06:27:13.874368+03	2025-04-06 15:27:13.874368+03	completed	2025-05-05 13:41:10.759212+03
652	driver12	2025-05-05 15:46:58.943042+03	2025-05-05 23:16:58.943042+03	completed	2025-05-05 13:41:10.759212+03
653	driver12	2025-05-04 07:01:48.09797+03	2025-05-04 16:01:48.09797+03	completed	2025-05-05 13:41:10.759212+03
654	driver12	2025-05-04 15:04:37.051025+03	2025-05-04 22:34:37.051025+03	completed	2025-05-05 13:41:10.759212+03
655	driver12	2025-05-03 07:18:58.785622+03	\N	cancelled	2025-05-05 13:41:10.759212+03
656	driver12	2025-05-02 06:20:13.645382+03	2025-05-02 15:20:13.645382+03	completed	2025-05-05 13:41:10.759212+03
657	driver12	2025-05-02 07:15:21.833543+03	2025-05-02 16:15:21.833543+03	completed	2025-05-05 13:41:10.759212+03
658	driver12	2025-05-01 05:53:42.842556+03	2025-05-01 14:53:42.842556+03	completed	2025-05-05 13:41:10.759212+03
659	driver12	2025-05-01 15:18:26.219249+03	2025-05-01 22:48:26.219249+03	completed	2025-05-05 13:41:10.759212+03
660	driver12	2025-04-30 06:44:44.153211+03	2025-04-30 15:44:44.153211+03	completed	2025-05-05 13:41:10.759212+03
661	driver12	2025-04-29 07:05:18.501917+03	\N	cancelled	2025-05-05 13:41:10.759212+03
662	driver12	2025-04-29 15:01:00.97665+03	2025-04-29 22:31:00.97665+03	completed	2025-05-05 13:41:10.759212+03
663	driver12	2025-04-28 05:37:35.346076+03	2025-04-28 14:37:35.346076+03	completed	2025-05-05 13:41:10.759212+03
664	driver12	2025-04-27 15:06:11.904701+03	2025-04-27 22:36:11.904701+03	completed	2025-05-05 13:41:10.759212+03
665	driver12	2025-04-26 15:53:14.341157+03	\N	cancelled	2025-05-05 13:41:10.759212+03
666	driver12	2025-04-26 15:43:25.513018+03	2025-04-26 23:13:25.513018+03	completed	2025-05-05 13:41:10.759212+03
667	driver12	2025-04-25 15:31:52.840777+03	2025-04-25 23:01:52.840777+03	completed	2025-05-05 13:41:10.759212+03
668	driver12	2025-04-25 15:38:00.65982+03	2025-04-25 23:08:00.65982+03	completed	2025-05-05 13:41:10.759212+03
669	driver12	2025-04-24 05:54:38.699872+03	2025-04-24 14:54:38.699872+03	completed	2025-05-05 13:41:10.759212+03
670	driver12	2025-04-23 15:00:10.313973+03	2025-04-23 22:30:10.313973+03	completed	2025-05-05 13:41:10.759212+03
671	driver12	2025-04-23 15:32:15.678938+03	\N	cancelled	2025-05-05 13:41:10.759212+03
672	driver12	2025-04-22 15:24:47.326481+03	2025-04-22 22:54:47.326481+03	completed	2025-05-05 13:41:10.759212+03
673	driver12	2025-04-21 15:38:13.493602+03	2025-04-21 23:08:13.493602+03	completed	2025-05-05 13:41:10.759212+03
674	driver12	2025-04-20 06:43:08.475566+03	2025-04-20 15:43:08.475566+03	completed	2025-05-05 13:41:10.759212+03
675	driver12	2025-04-20 06:52:17.020598+03	2025-04-20 15:52:17.020598+03	completed	2025-05-05 13:41:10.759212+03
676	driver12	2025-04-19 15:14:46.576088+03	2025-04-19 22:44:46.576088+03	completed	2025-05-05 13:41:10.759212+03
677	driver12	2025-04-18 15:29:49.971525+03	2025-04-18 22:59:49.971525+03	completed	2025-05-05 13:41:10.759212+03
678	driver12	2025-04-17 05:53:43.375965+03	2025-04-17 14:53:43.375965+03	completed	2025-05-05 13:41:10.759212+03
679	driver12	2025-04-17 15:39:38.969824+03	2025-04-17 23:09:38.969824+03	completed	2025-05-05 13:41:10.759212+03
680	driver12	2025-04-16 07:08:35.057315+03	2025-04-16 16:08:35.057315+03	completed	2025-05-05 13:41:10.759212+03
681	driver12	2025-04-15 07:19:22.932648+03	2025-04-15 16:19:22.932648+03	completed	2025-05-05 13:41:10.759212+03
682	driver12	2025-04-15 15:15:57.576921+03	\N	cancelled	2025-05-05 13:41:10.759212+03
683	driver12	2025-04-14 15:17:49.100856+03	2025-04-14 22:47:49.100856+03	completed	2025-05-05 13:41:10.759212+03
684	driver12	2025-04-14 06:52:55.494029+03	2025-04-14 15:52:55.494029+03	completed	2025-05-05 13:41:10.759212+03
685	driver12	2025-04-13 15:57:24.805536+03	2025-04-13 23:27:24.805536+03	completed	2025-05-05 13:41:10.759212+03
686	driver12	2025-04-13 05:42:15.520506+03	2025-04-13 14:42:15.520506+03	completed	2025-05-05 13:41:10.759212+03
687	driver12	2025-04-12 06:59:52.636376+03	2025-04-12 15:59:52.636376+03	completed	2025-05-05 13:41:10.759212+03
688	driver12	2025-04-12 15:18:34.05354+03	2025-04-12 22:48:34.05354+03	completed	2025-05-05 13:41:10.759212+03
689	driver12	2025-04-11 15:01:45.401485+03	2025-04-11 22:31:45.401485+03	completed	2025-05-05 13:41:10.759212+03
690	driver12	2025-04-11 15:31:00.316434+03	\N	cancelled	2025-05-05 13:41:10.759212+03
691	driver12	2025-04-10 15:01:47.887325+03	2025-04-10 22:31:47.887325+03	completed	2025-05-05 13:41:10.759212+03
692	driver12	2025-04-10 07:18:35.407537+03	2025-04-10 16:18:35.407537+03	completed	2025-05-05 13:41:10.759212+03
693	driver12	2025-04-09 15:32:30.823019+03	\N	cancelled	2025-05-05 13:41:10.759212+03
694	driver12	2025-04-09 07:09:00.16193+03	2025-04-09 16:09:00.16193+03	completed	2025-05-05 13:41:10.759212+03
695	driver12	2025-04-08 07:17:20.317728+03	2025-04-08 16:17:20.317728+03	completed	2025-05-05 13:41:10.759212+03
696	driver12	2025-04-07 15:17:24.753679+03	2025-04-07 22:47:24.753679+03	completed	2025-05-05 13:41:10.759212+03
697	driver12	2025-04-07 07:03:41.597063+03	\N	cancelled	2025-05-05 13:41:10.759212+03
698	driver12	2025-04-06 06:55:19.26734+03	2025-04-06 15:55:19.26734+03	completed	2025-05-05 13:41:10.759212+03
699	driver12	2025-04-06 07:09:30.550237+03	2025-04-06 16:09:30.550237+03	completed	2025-05-05 13:41:10.759212+03
700	driver3	2025-05-05 15:58:26.327202+03	2025-05-05 23:28:26.327202+03	completed	2025-05-05 13:41:10.759212+03
701	driver3	2025-05-05 06:42:42.063718+03	2025-05-05 15:42:42.063718+03	completed	2025-05-05 13:41:10.759212+03
702	driver3	2025-05-04 15:29:33.800464+03	2025-05-04 22:59:33.800464+03	completed	2025-05-05 13:41:10.759212+03
703	driver3	2025-05-04 05:54:22.067418+03	2025-05-04 14:54:22.067418+03	completed	2025-05-05 13:41:10.759212+03
704	driver3	2025-05-03 15:25:01.894498+03	2025-05-03 22:55:01.894498+03	completed	2025-05-05 13:41:10.759212+03
705	driver3	2025-05-03 15:33:04.971355+03	2025-05-03 23:03:04.971355+03	completed	2025-05-05 13:41:10.759212+03
706	driver3	2025-05-02 05:48:42.512755+03	2025-05-02 14:48:42.512755+03	completed	2025-05-05 13:41:10.759212+03
707	driver3	2025-05-01 07:26:11.025425+03	2025-05-01 16:26:11.025425+03	completed	2025-05-05 13:41:10.759212+03
708	driver3	2025-05-01 05:36:58.84852+03	2025-05-01 14:36:58.84852+03	completed	2025-05-05 13:41:10.759212+03
709	driver3	2025-04-30 07:28:51.083679+03	2025-04-30 16:28:51.083679+03	completed	2025-05-05 13:41:10.759212+03
710	driver3	2025-04-29 15:09:59.078078+03	2025-04-29 22:39:59.078078+03	completed	2025-05-05 13:41:10.759212+03
711	driver3	2025-04-28 15:05:35.664431+03	2025-04-28 22:35:35.664431+03	completed	2025-05-05 13:41:10.759212+03
712	driver3	2025-04-28 15:15:05.312793+03	2025-04-28 22:45:05.312793+03	completed	2025-05-05 13:41:10.759212+03
713	driver3	2025-04-27 15:35:37.825351+03	2025-04-27 23:05:37.825351+03	completed	2025-05-05 13:41:10.759212+03
714	driver3	2025-04-26 07:06:15.133253+03	2025-04-26 16:06:15.133253+03	completed	2025-05-05 13:41:10.759212+03
715	driver3	2025-04-26 06:29:19.162337+03	2025-04-26 15:29:19.162337+03	completed	2025-05-05 13:41:10.759212+03
716	driver3	2025-04-25 07:21:25.813288+03	2025-04-25 16:21:25.813288+03	completed	2025-05-05 13:41:10.759212+03
717	driver3	2025-04-24 15:31:03.574122+03	2025-04-24 23:01:03.574122+03	completed	2025-05-05 13:41:10.759212+03
718	driver3	2025-04-24 07:03:17.1293+03	2025-04-24 16:03:17.1293+03	completed	2025-05-05 13:41:10.759212+03
719	driver3	2025-04-23 15:19:31.758775+03	2025-04-23 22:49:31.758775+03	completed	2025-05-05 13:41:10.759212+03
720	driver3	2025-04-23 15:51:11.284779+03	2025-04-23 23:21:11.284779+03	completed	2025-05-05 13:41:10.759212+03
721	driver3	2025-04-22 06:24:50.2711+03	2025-04-22 15:24:50.2711+03	completed	2025-05-05 13:41:10.759212+03
722	driver3	2025-04-22 15:44:32.878325+03	2025-04-22 23:14:32.878325+03	completed	2025-05-05 13:41:10.759212+03
723	driver3	2025-04-21 15:36:22.588294+03	2025-04-21 23:06:22.588294+03	completed	2025-05-05 13:41:10.759212+03
724	driver3	2025-04-20 15:03:59.711421+03	2025-04-20 22:33:59.711421+03	completed	2025-05-05 13:41:10.759212+03
725	driver3	2025-04-20 15:42:32.62268+03	2025-04-20 23:12:32.62268+03	completed	2025-05-05 13:41:10.759212+03
726	driver3	2025-04-19 15:16:51.113827+03	2025-04-19 22:46:51.113827+03	completed	2025-05-05 13:41:10.759212+03
727	driver3	2025-04-19 15:40:53.797881+03	2025-04-19 23:10:53.797881+03	completed	2025-05-05 13:41:10.759212+03
728	driver3	2025-04-18 05:48:27.435466+03	2025-04-18 14:48:27.435466+03	completed	2025-05-05 13:41:10.759212+03
729	driver3	2025-04-18 15:38:30.536704+03	2025-04-18 23:08:30.536704+03	completed	2025-05-05 13:41:10.759212+03
730	driver3	2025-04-17 15:14:12.642805+03	2025-04-17 22:44:12.642805+03	completed	2025-05-05 13:41:10.759212+03
731	driver3	2025-04-17 06:58:34.130442+03	\N	cancelled	2025-05-05 13:41:10.759212+03
732	driver3	2025-04-16 15:55:04.936569+03	\N	cancelled	2025-05-05 13:41:10.759212+03
733	driver3	2025-04-16 07:10:04.435707+03	2025-04-16 16:10:04.435707+03	completed	2025-05-05 13:41:10.759212+03
734	driver3	2025-04-15 15:00:00.591159+03	2025-04-15 22:30:00.591159+03	completed	2025-05-05 13:41:10.759212+03
735	driver3	2025-04-14 07:10:12.172501+03	2025-04-14 16:10:12.172501+03	completed	2025-05-05 13:41:10.759212+03
736	driver3	2025-04-14 05:45:34.639994+03	2025-04-14 14:45:34.639994+03	completed	2025-05-05 13:41:10.759212+03
737	driver3	2025-04-13 06:44:15.631705+03	\N	cancelled	2025-05-05 13:41:10.759212+03
738	driver3	2025-04-13 07:08:26.961603+03	\N	cancelled	2025-05-05 13:41:10.759212+03
739	driver3	2025-04-12 06:05:43.397945+03	2025-04-12 15:05:43.397945+03	completed	2025-05-05 13:41:10.759212+03
740	driver3	2025-04-12 06:05:05.0346+03	\N	cancelled	2025-05-05 13:41:10.759212+03
741	driver3	2025-04-11 05:45:47.636436+03	\N	cancelled	2025-05-05 13:41:10.759212+03
742	driver3	2025-04-11 07:15:20.434546+03	\N	cancelled	2025-05-05 13:41:10.759212+03
743	driver3	2025-04-10 15:28:22.570889+03	2025-04-10 22:58:22.570889+03	completed	2025-05-05 13:41:10.759212+03
744	driver3	2025-04-10 07:05:17.818175+03	2025-04-10 16:05:17.818175+03	completed	2025-05-05 13:41:10.759212+03
745	driver3	2025-04-09 06:05:27.295363+03	2025-04-09 15:05:27.295363+03	completed	2025-05-05 13:41:10.759212+03
746	driver3	2025-04-09 05:31:47.713628+03	2025-04-09 14:31:47.713628+03	completed	2025-05-05 13:41:10.759212+03
747	driver3	2025-04-08 07:00:00.356753+03	2025-04-08 16:00:00.356753+03	completed	2025-05-05 13:41:10.759212+03
748	driver3	2025-04-08 05:49:27.491902+03	2025-04-08 14:49:27.491902+03	completed	2025-05-05 13:41:10.759212+03
749	driver3	2025-04-07 15:59:16.338959+03	2025-04-07 23:29:16.338959+03	completed	2025-05-05 13:41:10.759212+03
750	driver3	2025-04-07 15:18:50.265329+03	2025-04-07 22:48:50.265329+03	completed	2025-05-05 13:41:10.759212+03
751	driver3	2025-04-06 15:11:01.28486+03	2025-04-06 22:41:01.28486+03	completed	2025-05-05 13:41:10.759212+03
752	driver3	2025-04-06 15:39:27.057929+03	2025-04-06 23:09:27.057929+03	completed	2025-05-05 13:41:10.759212+03
753	driver4	2025-05-05 06:26:43.535891+03	2025-05-05 15:26:43.535891+03	completed	2025-05-05 13:41:10.759212+03
754	driver4	2025-05-05 06:36:10.453677+03	2025-05-05 15:36:10.453677+03	completed	2025-05-05 13:41:10.759212+03
755	driver4	2025-05-04 06:57:28.111988+03	\N	cancelled	2025-05-05 13:41:10.759212+03
756	driver4	2025-05-04 15:45:55.346601+03	2025-05-04 23:15:55.346601+03	completed	2025-05-05 13:41:10.759212+03
757	driver4	2025-05-03 15:46:02.709858+03	2025-05-03 23:16:02.709858+03	completed	2025-05-05 13:41:10.759212+03
758	driver4	2025-05-02 15:52:53.66535+03	\N	cancelled	2025-05-05 13:41:10.759212+03
759	driver4	2025-05-02 05:32:09.935272+03	2025-05-02 14:32:09.935272+03	completed	2025-05-05 13:41:10.759212+03
760	driver4	2025-05-01 06:06:49.914818+03	2025-05-01 15:06:49.914818+03	completed	2025-05-05 13:41:10.759212+03
761	driver4	2025-04-30 07:09:22.45289+03	2025-04-30 16:09:22.45289+03	completed	2025-05-05 13:41:10.759212+03
762	driver4	2025-04-29 07:02:08.641156+03	2025-04-29 16:02:08.641156+03	completed	2025-05-05 13:41:10.759212+03
763	driver4	2025-04-29 05:58:13.403539+03	2025-04-29 14:58:13.403539+03	completed	2025-05-05 13:41:10.759212+03
764	driver4	2025-04-28 05:54:23.231784+03	2025-04-28 14:54:23.231784+03	completed	2025-05-05 13:41:10.759212+03
765	driver4	2025-04-28 15:37:43.760882+03	2025-04-28 23:07:43.760882+03	completed	2025-05-05 13:41:10.759212+03
766	driver4	2025-04-27 05:32:44.576644+03	\N	cancelled	2025-05-05 13:41:10.759212+03
767	driver4	2025-04-27 07:23:43.003851+03	2025-04-27 16:23:43.003851+03	completed	2025-05-05 13:41:10.759212+03
768	driver4	2025-04-26 15:19:24.753505+03	2025-04-26 22:49:24.753505+03	completed	2025-05-05 13:41:10.759212+03
769	driver4	2025-04-26 06:02:49.269301+03	2025-04-26 15:02:49.269301+03	completed	2025-05-05 13:41:10.759212+03
770	driver4	2025-04-25 05:39:12.273893+03	2025-04-25 14:39:12.273893+03	completed	2025-05-05 13:41:10.759212+03
771	driver4	2025-04-24 05:48:36.840513+03	2025-04-24 14:48:36.840513+03	completed	2025-05-05 13:41:10.759212+03
772	driver4	2025-04-24 06:22:25.595843+03	2025-04-24 15:22:25.595843+03	completed	2025-05-05 13:41:10.759212+03
773	driver4	2025-04-23 15:40:45.098936+03	2025-04-23 23:10:45.098936+03	completed	2025-05-05 13:41:10.759212+03
774	driver4	2025-04-23 06:28:08.469147+03	2025-04-23 15:28:08.469147+03	completed	2025-05-05 13:41:10.759212+03
775	driver4	2025-04-22 15:11:04.336884+03	2025-04-22 22:41:04.336884+03	completed	2025-05-05 13:41:10.759212+03
776	driver4	2025-04-21 07:16:08.965763+03	2025-04-21 16:16:08.965763+03	completed	2025-05-05 13:41:10.759212+03
777	driver4	2025-04-20 07:29:41.654205+03	2025-04-20 16:29:41.654205+03	completed	2025-05-05 13:41:10.759212+03
778	driver4	2025-04-20 07:20:02.169114+03	2025-04-20 16:20:02.169114+03	completed	2025-05-05 13:41:10.759212+03
779	driver4	2025-04-19 07:26:43.767118+03	\N	cancelled	2025-05-05 13:41:10.759212+03
780	driver4	2025-04-18 05:38:02.39197+03	\N	cancelled	2025-05-05 13:41:10.759212+03
781	driver4	2025-04-17 06:14:27.890691+03	2025-04-17 15:14:27.890691+03	completed	2025-05-05 13:41:10.759212+03
782	driver4	2025-04-17 15:49:23.182383+03	\N	cancelled	2025-05-05 13:41:10.759212+03
783	driver4	2025-04-16 07:09:03.947518+03	2025-04-16 16:09:03.947518+03	completed	2025-05-05 13:41:10.759212+03
784	driver4	2025-04-16 07:28:14.503325+03	2025-04-16 16:28:14.503325+03	completed	2025-05-05 13:41:10.759212+03
785	driver4	2025-04-15 05:53:29.542847+03	\N	cancelled	2025-05-05 13:41:10.759212+03
786	driver4	2025-04-15 06:10:44.768297+03	2025-04-15 15:10:44.768297+03	completed	2025-05-05 13:41:10.759212+03
787	driver4	2025-04-14 15:19:26.702312+03	2025-04-14 22:49:26.702312+03	completed	2025-05-05 13:41:10.759212+03
788	driver4	2025-04-13 15:15:47.215829+03	2025-04-13 22:45:47.215829+03	completed	2025-05-05 13:41:10.759212+03
789	driver4	2025-04-13 06:03:22.411871+03	2025-04-13 15:03:22.411871+03	completed	2025-05-05 13:41:10.759212+03
790	driver4	2025-04-12 06:20:07.920538+03	2025-04-12 15:20:07.920538+03	completed	2025-05-05 13:41:10.759212+03
791	driver4	2025-04-11 07:05:31.393928+03	2025-04-11 16:05:31.393928+03	completed	2025-05-05 13:41:10.759212+03
792	driver4	2025-04-11 15:36:39.67321+03	2025-04-11 23:06:39.67321+03	completed	2025-05-05 13:41:10.759212+03
793	driver4	2025-04-10 06:09:09.541427+03	2025-04-10 15:09:09.541427+03	completed	2025-05-05 13:41:10.759212+03
794	driver4	2025-04-10 15:51:07.065716+03	2025-04-10 23:21:07.065716+03	completed	2025-05-05 13:41:10.759212+03
795	driver4	2025-04-09 05:31:38.630742+03	2025-04-09 14:31:38.630742+03	completed	2025-05-05 13:41:10.759212+03
796	driver4	2025-04-09 05:55:11.222453+03	2025-04-09 14:55:11.222453+03	completed	2025-05-05 13:41:10.759212+03
797	driver4	2025-04-08 15:04:36.669593+03	2025-04-08 22:34:36.669593+03	completed	2025-05-05 13:41:10.759212+03
798	driver4	2025-04-08 06:12:12.235925+03	2025-04-08 15:12:12.235925+03	completed	2025-05-05 13:41:10.759212+03
799	driver4	2025-04-07 15:38:49.837387+03	2025-04-07 23:08:49.837387+03	completed	2025-05-05 13:41:10.759212+03
800	driver4	2025-04-07 15:20:26.269171+03	2025-04-07 22:50:26.269171+03	completed	2025-05-05 13:41:10.759212+03
801	driver4	2025-04-06 07:26:56.489885+03	2025-04-06 16:26:56.489885+03	completed	2025-05-05 13:41:10.759212+03
802	driver4	2025-04-06 15:35:41.677939+03	2025-04-06 23:05:41.677939+03	completed	2025-05-05 13:41:10.759212+03
803	driver5	2025-05-05 15:24:48.967218+03	2025-05-05 22:54:48.967218+03	completed	2025-05-05 13:41:10.759212+03
804	driver5	2025-05-05 15:36:26.737075+03	2025-05-05 23:06:26.737075+03	completed	2025-05-05 13:41:10.759212+03
805	driver5	2025-05-04 15:52:29.149033+03	2025-05-04 23:22:29.149033+03	completed	2025-05-05 13:41:10.759212+03
806	driver5	2025-05-03 15:51:37.465832+03	2025-05-03 23:21:37.465832+03	completed	2025-05-05 13:41:10.759212+03
807	driver5	2025-05-02 06:17:27.526944+03	\N	cancelled	2025-05-05 13:41:10.759212+03
808	driver5	2025-05-02 06:09:06.512705+03	2025-05-02 15:09:06.512705+03	completed	2025-05-05 13:41:10.759212+03
809	driver5	2025-05-01 06:46:42.394159+03	2025-05-01 15:46:42.394159+03	completed	2025-05-05 13:41:10.759212+03
810	driver5	2025-04-30 15:22:51.347858+03	\N	cancelled	2025-05-05 13:41:10.759212+03
811	driver5	2025-04-30 05:42:52.749599+03	2025-04-30 14:42:52.749599+03	completed	2025-05-05 13:41:10.759212+03
812	driver5	2025-04-29 07:18:30.063994+03	2025-04-29 16:18:30.063994+03	completed	2025-05-05 13:41:10.759212+03
813	driver5	2025-04-29 06:31:44.87107+03	2025-04-29 15:31:44.87107+03	completed	2025-05-05 13:41:10.759212+03
814	driver5	2025-04-28 05:41:21.256494+03	2025-04-28 14:41:21.256494+03	completed	2025-05-05 13:41:10.759212+03
815	driver5	2025-04-27 15:23:04.263806+03	2025-04-27 22:53:04.263806+03	completed	2025-05-05 13:41:10.759212+03
816	driver5	2025-04-27 05:31:14.27055+03	2025-04-27 14:31:14.27055+03	completed	2025-05-05 13:41:10.759212+03
817	driver5	2025-04-26 05:57:41.536074+03	2025-04-26 14:57:41.536074+03	completed	2025-05-05 13:41:10.759212+03
818	driver5	2025-04-26 15:18:53.056721+03	2025-04-26 22:48:53.056721+03	completed	2025-05-05 13:41:10.759212+03
819	driver5	2025-04-25 06:45:41.230264+03	2025-04-25 15:45:41.230264+03	completed	2025-05-05 13:41:10.759212+03
820	driver5	2025-04-25 06:17:25.728031+03	\N	cancelled	2025-05-05 13:41:10.759212+03
821	driver5	2025-04-24 06:58:59.722301+03	2025-04-24 15:58:59.722301+03	completed	2025-05-05 13:41:10.759212+03
822	driver5	2025-04-23 15:14:06.926157+03	2025-04-23 22:44:06.926157+03	completed	2025-05-05 13:41:10.759212+03
823	driver5	2025-04-23 06:32:32.129052+03	2025-04-23 15:32:32.129052+03	completed	2025-05-05 13:41:10.759212+03
824	driver5	2025-04-22 07:20:00.123475+03	2025-04-22 16:20:00.123475+03	completed	2025-05-05 13:41:10.759212+03
825	driver5	2025-04-21 15:28:24.225522+03	2025-04-21 22:58:24.225522+03	completed	2025-05-05 13:41:10.759212+03
826	driver5	2025-04-20 06:06:38.172864+03	2025-04-20 15:06:38.172864+03	completed	2025-05-05 13:41:10.759212+03
827	driver5	2025-04-19 15:49:39.775734+03	2025-04-19 23:19:39.775734+03	completed	2025-05-05 13:41:10.759212+03
828	driver5	2025-04-19 15:02:15.501776+03	2025-04-19 22:32:15.501776+03	completed	2025-05-05 13:41:10.759212+03
829	driver5	2025-04-18 06:48:29.90292+03	2025-04-18 15:48:29.90292+03	completed	2025-05-05 13:41:10.759212+03
830	driver5	2025-04-17 15:00:29.8435+03	2025-04-17 22:30:29.8435+03	completed	2025-05-05 13:41:10.759212+03
831	driver5	2025-04-16 05:30:49.695659+03	2025-04-16 14:30:49.695659+03	completed	2025-05-05 13:41:10.759212+03
832	driver5	2025-04-15 15:05:01.387922+03	2025-04-15 22:35:01.387922+03	completed	2025-05-05 13:41:10.759212+03
833	driver5	2025-04-14 05:37:09.279946+03	2025-04-14 14:37:09.279946+03	completed	2025-05-05 13:41:10.759212+03
834	driver5	2025-04-14 15:16:49.275444+03	2025-04-14 22:46:49.275444+03	completed	2025-05-05 13:41:10.759212+03
835	driver5	2025-04-13 07:04:09.903477+03	2025-04-13 16:04:09.903477+03	completed	2025-05-05 13:41:10.759212+03
836	driver5	2025-04-13 06:03:42.907993+03	2025-04-13 15:03:42.907993+03	completed	2025-05-05 13:41:10.759212+03
837	driver5	2025-04-12 15:46:10.838115+03	2025-04-12 23:16:10.838115+03	completed	2025-05-05 13:41:10.759212+03
838	driver5	2025-04-12 15:09:18.931975+03	2025-04-12 22:39:18.931975+03	completed	2025-05-05 13:41:10.759212+03
839	driver5	2025-04-11 07:12:27.272771+03	2025-04-11 16:12:27.272771+03	completed	2025-05-05 13:41:10.759212+03
840	driver5	2025-04-11 07:08:04.192168+03	2025-04-11 16:08:04.192168+03	completed	2025-05-05 13:41:10.759212+03
841	driver5	2025-04-10 06:34:35.932714+03	2025-04-10 15:34:35.932714+03	completed	2025-05-05 13:41:10.759212+03
842	driver5	2025-04-09 06:55:48.977619+03	\N	cancelled	2025-05-05 13:41:10.759212+03
843	driver5	2025-04-08 06:08:40.056239+03	2025-04-08 15:08:40.056239+03	completed	2025-05-05 13:41:10.759212+03
844	driver5	2025-04-07 07:08:31.738636+03	2025-04-07 16:08:31.738636+03	completed	2025-05-05 13:41:10.759212+03
845	driver5	2025-04-07 05:56:13.504802+03	\N	cancelled	2025-05-05 13:41:10.759212+03
846	driver5	2025-04-06 15:25:04.163562+03	2025-04-06 22:55:04.163562+03	completed	2025-05-05 13:41:10.759212+03
847	driver5	2025-04-06 06:46:10.113446+03	2025-04-06 15:46:10.113446+03	completed	2025-05-05 13:41:10.759212+03
848	driver6	2025-05-05 06:50:13.690575+03	2025-05-05 15:50:13.690575+03	completed	2025-05-05 13:41:10.759212+03
849	driver6	2025-05-04 06:01:21.176578+03	2025-05-04 15:01:21.176578+03	completed	2025-05-05 13:41:10.759212+03
850	driver6	2025-05-03 06:10:43.776729+03	2025-05-03 15:10:43.776729+03	completed	2025-05-05 13:41:10.759212+03
851	driver6	2025-05-02 15:45:49.452223+03	2025-05-02 23:15:49.452223+03	completed	2025-05-05 13:41:10.759212+03
852	driver6	2025-05-02 15:18:06.675192+03	2025-05-02 22:48:06.675192+03	completed	2025-05-05 13:41:10.759212+03
853	driver6	2025-05-01 15:49:31.32962+03	2025-05-01 23:19:31.32962+03	completed	2025-05-05 13:41:10.759212+03
854	driver6	2025-05-01 07:09:24.474938+03	2025-05-01 16:09:24.474938+03	completed	2025-05-05 13:41:10.759212+03
855	driver6	2025-04-30 06:36:41.245272+03	2025-04-30 15:36:41.245272+03	completed	2025-05-05 13:41:10.759212+03
856	driver6	2025-04-30 07:05:32.412261+03	2025-04-30 16:05:32.412261+03	completed	2025-05-05 13:41:10.759212+03
857	driver6	2025-04-29 15:38:48.250759+03	2025-04-29 23:08:48.250759+03	completed	2025-05-05 13:41:10.759212+03
858	driver6	2025-04-29 07:28:08.679334+03	2025-04-29 16:28:08.679334+03	completed	2025-05-05 13:41:10.759212+03
859	driver6	2025-04-28 15:38:52.720791+03	2025-04-28 23:08:52.720791+03	completed	2025-05-05 13:41:10.759212+03
860	driver6	2025-04-27 15:55:58.820782+03	2025-04-27 23:25:58.820782+03	completed	2025-05-05 13:41:10.759212+03
861	driver6	2025-04-26 15:42:04.976122+03	2025-04-26 23:12:04.976122+03	completed	2025-05-05 13:41:10.759212+03
862	driver6	2025-04-25 07:14:38.414767+03	2025-04-25 16:14:38.414767+03	completed	2025-05-05 13:41:10.759212+03
863	driver6	2025-04-24 15:19:41.921196+03	2025-04-24 22:49:41.921196+03	completed	2025-05-05 13:41:10.759212+03
864	driver6	2025-04-23 05:53:20.047512+03	2025-04-23 14:53:20.047512+03	completed	2025-05-05 13:41:10.759212+03
865	driver6	2025-04-23 06:39:05.022345+03	2025-04-23 15:39:05.022345+03	completed	2025-05-05 13:41:10.759212+03
866	driver6	2025-04-22 15:27:05.46745+03	2025-04-22 22:57:05.46745+03	completed	2025-05-05 13:41:10.759212+03
867	driver6	2025-04-21 15:58:05.786914+03	2025-04-21 23:28:05.786914+03	completed	2025-05-05 13:41:10.759212+03
868	driver6	2025-04-21 07:02:28.647188+03	2025-04-21 16:02:28.647188+03	completed	2025-05-05 13:41:10.759212+03
869	driver6	2025-04-20 06:45:55.157092+03	2025-04-20 15:45:55.157092+03	completed	2025-05-05 13:41:10.759212+03
870	driver6	2025-04-19 15:24:17.301103+03	2025-04-19 22:54:17.301103+03	completed	2025-05-05 13:41:10.759212+03
871	driver6	2025-04-18 15:31:58.786893+03	2025-04-18 23:01:58.786893+03	completed	2025-05-05 13:41:10.759212+03
872	driver6	2025-04-17 06:55:06.161119+03	2025-04-17 15:55:06.161119+03	completed	2025-05-05 13:41:10.759212+03
873	driver6	2025-04-17 05:47:06.96451+03	2025-04-17 14:47:06.96451+03	completed	2025-05-05 13:41:10.759212+03
874	driver6	2025-04-16 06:04:11.147624+03	2025-04-16 15:04:11.147624+03	completed	2025-05-05 13:41:10.759212+03
875	driver6	2025-04-15 06:40:44.81391+03	2025-04-15 15:40:44.81391+03	completed	2025-05-05 13:41:10.759212+03
876	driver6	2025-04-15 06:18:51.384006+03	2025-04-15 15:18:51.384006+03	completed	2025-05-05 13:41:10.759212+03
877	driver6	2025-04-14 15:20:21.142678+03	2025-04-14 22:50:21.142678+03	completed	2025-05-05 13:41:10.759212+03
878	driver6	2025-04-14 15:39:23.831218+03	\N	cancelled	2025-05-05 13:41:10.759212+03
879	driver6	2025-04-13 06:19:24.866887+03	2025-04-13 15:19:24.866887+03	completed	2025-05-05 13:41:10.759212+03
880	driver6	2025-04-13 15:50:20.649341+03	2025-04-13 23:20:20.649341+03	completed	2025-05-05 13:41:10.759212+03
881	driver6	2025-04-12 06:30:19.526482+03	2025-04-12 15:30:19.526482+03	completed	2025-05-05 13:41:10.759212+03
882	driver6	2025-04-12 05:43:23.816983+03	2025-04-12 14:43:23.816983+03	completed	2025-05-05 13:41:10.759212+03
883	driver6	2025-04-11 06:57:41.071129+03	2025-04-11 15:57:41.071129+03	completed	2025-05-05 13:41:10.759212+03
884	driver6	2025-04-10 15:11:15.160357+03	2025-04-10 22:41:15.160357+03	completed	2025-05-05 13:41:10.759212+03
885	driver6	2025-04-09 06:22:06.246991+03	2025-04-09 15:22:06.246991+03	completed	2025-05-05 13:41:10.759212+03
886	driver6	2025-04-08 15:40:34.742122+03	2025-04-08 23:10:34.742122+03	completed	2025-05-05 13:41:10.759212+03
887	driver6	2025-04-08 06:38:01.21007+03	2025-04-08 15:38:01.21007+03	completed	2025-05-05 13:41:10.759212+03
888	driver6	2025-04-07 06:09:46.995077+03	2025-04-07 15:09:46.995077+03	completed	2025-05-05 13:41:10.759212+03
889	driver6	2025-04-07 06:02:05.366617+03	2025-04-07 15:02:05.366617+03	completed	2025-05-05 13:41:10.759212+03
890	driver6	2025-04-06 05:37:07.973519+03	2025-04-06 14:37:07.973519+03	completed	2025-05-05 13:41:10.759212+03
891	driver7	2025-05-05 07:06:07.749351+03	2025-05-05 16:06:07.749351+03	completed	2025-05-05 13:41:10.759212+03
892	driver7	2025-05-04 15:29:50.966563+03	2025-05-04 22:59:50.966563+03	completed	2025-05-05 13:41:10.759212+03
893	driver7	2025-05-04 06:51:07.509484+03	2025-05-04 15:51:07.509484+03	completed	2025-05-05 13:41:10.759212+03
894	driver7	2025-05-03 06:25:38.761539+03	2025-05-03 15:25:38.761539+03	completed	2025-05-05 13:41:10.759212+03
895	driver7	2025-05-02 06:46:00.018656+03	2025-05-02 15:46:00.018656+03	completed	2025-05-05 13:41:10.759212+03
896	driver7	2025-05-01 05:34:43.862223+03	2025-05-01 14:34:43.862223+03	completed	2025-05-05 13:41:10.759212+03
897	driver7	2025-04-30 05:43:53.60646+03	2025-04-30 14:43:53.60646+03	completed	2025-05-05 13:41:10.759212+03
898	driver7	2025-04-30 15:22:09.639735+03	2025-04-30 22:52:09.639735+03	completed	2025-05-05 13:41:10.759212+03
899	driver7	2025-04-29 15:42:10.662808+03	2025-04-29 23:12:10.662808+03	completed	2025-05-05 13:41:10.759212+03
900	driver7	2025-04-29 06:00:24.84165+03	2025-04-29 15:00:24.84165+03	completed	2025-05-05 13:41:10.759212+03
901	driver7	2025-04-28 15:17:59.78269+03	2025-04-28 22:47:59.78269+03	completed	2025-05-05 13:41:10.759212+03
902	driver7	2025-04-28 07:01:15.018651+03	2025-04-28 16:01:15.018651+03	completed	2025-05-05 13:41:10.759212+03
903	driver7	2025-04-27 07:18:37.465422+03	2025-04-27 16:18:37.465422+03	completed	2025-05-05 13:41:10.759212+03
904	driver7	2025-04-27 06:01:34.228621+03	2025-04-27 15:01:34.228621+03	completed	2025-05-05 13:41:10.759212+03
905	driver7	2025-04-26 05:37:29.700458+03	2025-04-26 14:37:29.700458+03	completed	2025-05-05 13:41:10.759212+03
906	driver7	2025-04-25 06:47:25.878237+03	2025-04-25 15:47:25.878237+03	completed	2025-05-05 13:41:10.759212+03
907	driver7	2025-04-25 05:42:34.500036+03	2025-04-25 14:42:34.500036+03	completed	2025-05-05 13:41:10.759212+03
908	driver7	2025-04-24 06:39:33.644278+03	2025-04-24 15:39:33.644278+03	completed	2025-05-05 13:41:10.759212+03
909	driver7	2025-04-24 15:55:38.615977+03	2025-04-24 23:25:38.615977+03	completed	2025-05-05 13:41:10.759212+03
910	driver7	2025-04-23 15:39:02.088461+03	2025-04-23 23:09:02.088461+03	completed	2025-05-05 13:41:10.759212+03
911	driver7	2025-04-22 06:05:39.022802+03	2025-04-22 15:05:39.022802+03	completed	2025-05-05 13:41:10.759212+03
912	driver7	2025-04-21 07:04:12.550346+03	2025-04-21 16:04:12.550346+03	completed	2025-05-05 13:41:10.759212+03
913	driver7	2025-04-20 15:42:30.379937+03	2025-04-20 23:12:30.379937+03	completed	2025-05-05 13:41:10.759212+03
914	driver7	2025-04-20 06:20:40.705233+03	\N	cancelled	2025-05-05 13:41:10.759212+03
915	driver7	2025-04-19 06:15:53.588851+03	2025-04-19 15:15:53.588851+03	completed	2025-05-05 13:41:10.759212+03
916	driver7	2025-04-18 15:02:18.459936+03	2025-04-18 22:32:18.459936+03	completed	2025-05-05 13:41:10.759212+03
917	driver7	2025-04-17 15:19:05.794056+03	2025-04-17 22:49:05.794056+03	completed	2025-05-05 13:41:10.759212+03
918	driver7	2025-04-17 06:32:33.815287+03	\N	cancelled	2025-05-05 13:41:10.759212+03
919	driver7	2025-04-16 15:09:10.079693+03	2025-04-16 22:39:10.079693+03	completed	2025-05-05 13:41:10.759212+03
920	driver7	2025-04-15 07:04:24.463424+03	2025-04-15 16:04:24.463424+03	completed	2025-05-05 13:41:10.759212+03
921	driver7	2025-04-14 07:01:50.658797+03	2025-04-14 16:01:50.658797+03	completed	2025-05-05 13:41:10.759212+03
922	driver7	2025-04-13 15:22:08.983335+03	2025-04-13 22:52:08.983335+03	completed	2025-05-05 13:41:10.759212+03
923	driver7	2025-04-13 15:53:01.620655+03	2025-04-13 23:23:01.620655+03	completed	2025-05-05 13:41:10.759212+03
924	driver7	2025-04-12 15:28:36.991378+03	2025-04-12 22:58:36.991378+03	completed	2025-05-05 13:41:10.759212+03
925	driver7	2025-04-11 06:43:17.75328+03	2025-04-11 15:43:17.75328+03	completed	2025-05-05 13:41:10.759212+03
926	driver7	2025-04-11 15:54:54.45944+03	2025-04-11 23:24:54.45944+03	completed	2025-05-05 13:41:10.759212+03
927	driver7	2025-04-10 15:06:31.505546+03	2025-04-10 22:36:31.505546+03	completed	2025-05-05 13:41:10.759212+03
928	driver7	2025-04-09 15:55:47.730796+03	2025-04-09 23:25:47.730796+03	completed	2025-05-05 13:41:10.759212+03
929	driver7	2025-04-09 06:02:11.95391+03	\N	cancelled	2025-05-05 13:41:10.759212+03
930	driver7	2025-04-08 15:07:11.305749+03	\N	cancelled	2025-05-05 13:41:10.759212+03
931	driver7	2025-04-07 15:57:11.247701+03	2025-04-07 23:27:11.247701+03	completed	2025-05-05 13:41:10.759212+03
932	driver7	2025-04-06 07:03:32.752058+03	2025-04-06 16:03:32.752058+03	completed	2025-05-05 13:41:10.759212+03
933	driver7	2025-04-06 06:12:23.557993+03	2025-04-06 15:12:23.557993+03	completed	2025-05-05 13:41:10.759212+03
934	driver8	2025-05-05 06:33:18.636029+03	2025-05-05 15:33:18.636029+03	completed	2025-05-05 13:41:10.759212+03
935	driver8	2025-05-05 05:38:18.050636+03	2025-05-05 14:38:18.050636+03	completed	2025-05-05 13:41:10.759212+03
936	driver8	2025-05-04 06:14:25.05225+03	2025-05-04 15:14:25.05225+03	completed	2025-05-05 13:41:10.759212+03
937	driver8	2025-05-04 15:13:00.933476+03	2025-05-04 22:43:00.933476+03	completed	2025-05-05 13:41:10.759212+03
938	driver8	2025-05-03 15:25:10.252365+03	2025-05-03 22:55:10.252365+03	completed	2025-05-05 13:41:10.759212+03
939	driver8	2025-05-03 07:13:31.050649+03	2025-05-03 16:13:31.050649+03	completed	2025-05-05 13:41:10.759212+03
940	driver8	2025-05-02 07:05:36.024391+03	2025-05-02 16:05:36.024391+03	completed	2025-05-05 13:41:10.759212+03
941	driver8	2025-05-02 15:17:34.579234+03	2025-05-02 22:47:34.579234+03	completed	2025-05-05 13:41:10.759212+03
942	driver8	2025-05-01 06:10:18.371167+03	2025-05-01 15:10:18.371167+03	completed	2025-05-05 13:41:10.759212+03
943	driver8	2025-05-01 15:44:49.033546+03	\N	cancelled	2025-05-05 13:41:10.759212+03
944	driver8	2025-04-30 05:52:47.670116+03	2025-04-30 14:52:47.670116+03	completed	2025-05-05 13:41:10.759212+03
945	driver8	2025-04-29 15:59:26.016439+03	2025-04-29 23:29:26.016439+03	completed	2025-05-05 13:41:10.759212+03
946	driver8	2025-04-29 07:24:10.071663+03	2025-04-29 16:24:10.071663+03	completed	2025-05-05 13:41:10.759212+03
947	driver8	2025-04-28 15:39:32.629592+03	2025-04-28 23:09:32.629592+03	completed	2025-05-05 13:41:10.759212+03
948	driver8	2025-04-28 15:53:17.448296+03	2025-04-28 23:23:17.448296+03	completed	2025-05-05 13:41:10.759212+03
949	driver8	2025-04-27 06:07:50.181513+03	2025-04-27 15:07:50.181513+03	completed	2025-05-05 13:41:10.759212+03
950	driver8	2025-04-26 15:13:13.177379+03	2025-04-26 22:43:13.177379+03	completed	2025-05-05 13:41:10.759212+03
951	driver8	2025-04-26 15:39:06.622084+03	2025-04-26 23:09:06.622084+03	completed	2025-05-05 13:41:10.759212+03
952	driver8	2025-04-25 05:30:49.192798+03	2025-04-25 14:30:49.192798+03	completed	2025-05-05 13:41:10.759212+03
953	driver8	2025-04-25 06:12:59.453616+03	2025-04-25 15:12:59.453616+03	completed	2025-05-05 13:41:10.759212+03
954	driver8	2025-04-24 06:11:58.073668+03	2025-04-24 15:11:58.073668+03	completed	2025-05-05 13:41:10.759212+03
955	driver8	2025-04-24 07:29:15.359304+03	2025-04-24 16:29:15.359304+03	completed	2025-05-05 13:41:10.759212+03
956	driver8	2025-04-23 06:59:48.796155+03	2025-04-23 15:59:48.796155+03	completed	2025-05-05 13:41:10.759212+03
957	driver8	2025-04-22 15:18:53.16432+03	2025-04-22 22:48:53.16432+03	completed	2025-05-05 13:41:10.759212+03
958	driver8	2025-04-22 06:58:42.2396+03	2025-04-22 15:58:42.2396+03	completed	2025-05-05 13:41:10.759212+03
959	driver8	2025-04-21 15:25:24.133806+03	2025-04-21 22:55:24.133806+03	completed	2025-05-05 13:41:10.759212+03
960	driver8	2025-04-21 05:40:55.241106+03	\N	cancelled	2025-05-05 13:41:10.759212+03
961	driver8	2025-04-20 15:01:35.929404+03	2025-04-20 22:31:35.929404+03	completed	2025-05-05 13:41:10.759212+03
962	driver8	2025-04-20 15:31:44.421903+03	2025-04-20 23:01:44.421903+03	completed	2025-05-05 13:41:10.759212+03
963	driver8	2025-04-19 06:36:11.878676+03	2025-04-19 15:36:11.878676+03	completed	2025-05-05 13:41:10.759212+03
964	driver8	2025-04-18 06:08:44.242766+03	\N	cancelled	2025-05-05 13:41:10.759212+03
965	driver8	2025-04-17 15:33:18.252475+03	2025-04-17 23:03:18.252475+03	completed	2025-05-05 13:41:10.759212+03
966	driver8	2025-04-17 15:01:08.124462+03	2025-04-17 22:31:08.124462+03	completed	2025-05-05 13:41:10.759212+03
967	driver8	2025-04-16 05:51:07.246976+03	2025-04-16 14:51:07.246976+03	completed	2025-05-05 13:41:10.759212+03
968	driver8	2025-04-16 15:10:35.300201+03	2025-04-16 22:40:35.300201+03	completed	2025-05-05 13:41:10.759212+03
969	driver8	2025-04-15 15:14:53.83419+03	2025-04-15 22:44:53.83419+03	completed	2025-05-05 13:41:10.759212+03
970	driver8	2025-04-15 06:01:11.378193+03	2025-04-15 15:01:11.378193+03	completed	2025-05-05 13:41:10.759212+03
971	driver8	2025-04-14 06:06:34.034795+03	2025-04-14 15:06:34.034795+03	completed	2025-05-05 13:41:10.759212+03
972	driver8	2025-04-13 07:02:50.105708+03	2025-04-13 16:02:50.105708+03	completed	2025-05-05 13:41:10.759212+03
973	driver8	2025-04-12 15:57:32.02865+03	2025-04-12 23:27:32.02865+03	completed	2025-05-05 13:41:10.759212+03
974	driver8	2025-04-12 15:11:58.957958+03	2025-04-12 22:41:58.957958+03	completed	2025-05-05 13:41:10.759212+03
975	driver8	2025-04-11 06:20:30.676472+03	2025-04-11 15:20:30.676472+03	completed	2025-05-05 13:41:10.759212+03
976	driver8	2025-04-11 05:49:56.952535+03	\N	cancelled	2025-05-05 13:41:10.759212+03
977	driver8	2025-04-10 07:00:24.336442+03	2025-04-10 16:00:24.336442+03	completed	2025-05-05 13:41:10.759212+03
978	driver8	2025-04-09 15:46:43.249533+03	2025-04-09 23:16:43.249533+03	completed	2025-05-05 13:41:10.759212+03
979	driver8	2025-04-09 07:23:32.105529+03	2025-04-09 16:23:32.105529+03	completed	2025-05-05 13:41:10.759212+03
980	driver8	2025-04-08 15:16:43.984278+03	2025-04-08 22:46:43.984278+03	completed	2025-05-05 13:41:10.759212+03
981	driver8	2025-04-07 15:57:34.440305+03	2025-04-07 23:27:34.440305+03	completed	2025-05-05 13:41:10.759212+03
982	driver8	2025-04-07 06:14:57.244858+03	2025-04-07 15:14:57.244858+03	completed	2025-05-05 13:41:10.759212+03
983	driver8	2025-04-06 06:16:43.35265+03	2025-04-06 15:16:43.35265+03	completed	2025-05-05 13:41:10.759212+03
984	driver9	2025-05-05 15:37:37.652296+03	2025-05-05 23:07:37.652296+03	completed	2025-05-05 13:41:10.759212+03
985	driver9	2025-05-04 07:15:58.906685+03	2025-05-04 16:15:58.906685+03	completed	2025-05-05 13:41:10.759212+03
986	driver9	2025-05-03 06:56:13.34294+03	2025-05-03 15:56:13.34294+03	completed	2025-05-05 13:41:10.759212+03
987	driver9	2025-05-02 15:32:31.11063+03	2025-05-02 23:02:31.11063+03	completed	2025-05-05 13:41:10.759212+03
988	driver9	2025-05-01 15:19:13.936921+03	2025-05-01 22:49:13.936921+03	completed	2025-05-05 13:41:10.759212+03
989	driver9	2025-05-01 05:47:15.522505+03	2025-05-01 14:47:15.522505+03	completed	2025-05-05 13:41:10.759212+03
990	driver9	2025-04-30 05:37:46.517329+03	2025-04-30 14:37:46.517329+03	completed	2025-05-05 13:41:10.759212+03
991	driver9	2025-04-29 15:21:57.636327+03	2025-04-29 22:51:57.636327+03	completed	2025-05-05 13:41:10.759212+03
992	driver9	2025-04-28 15:14:11.905146+03	2025-04-28 22:44:11.905146+03	completed	2025-05-05 13:41:10.759212+03
993	driver9	2025-04-27 05:59:06.86063+03	2025-04-27 14:59:06.86063+03	completed	2025-05-05 13:41:10.759212+03
994	driver9	2025-04-26 06:18:46.568295+03	2025-04-26 15:18:46.568295+03	completed	2025-05-05 13:41:10.759212+03
995	driver9	2025-04-26 06:36:30.655255+03	2025-04-26 15:36:30.655255+03	completed	2025-05-05 13:41:10.759212+03
996	driver9	2025-04-25 15:52:47.406273+03	2025-04-25 23:22:47.406273+03	completed	2025-05-05 13:41:10.759212+03
997	driver9	2025-04-25 05:43:04.741884+03	2025-04-25 14:43:04.741884+03	completed	2025-05-05 13:41:10.759212+03
998	driver9	2025-04-24 07:14:42.125226+03	\N	cancelled	2025-05-05 13:41:10.759212+03
999	driver9	2025-04-24 06:55:03.23554+03	2025-04-24 15:55:03.23554+03	completed	2025-05-05 13:41:10.759212+03
1000	driver9	2025-04-23 15:07:48.657304+03	2025-04-23 22:37:48.657304+03	completed	2025-05-05 13:41:10.759212+03
1001	driver9	2025-04-23 15:14:19.491085+03	2025-04-23 22:44:19.491085+03	completed	2025-05-05 13:41:10.759212+03
1002	driver9	2025-04-22 05:49:18.353635+03	2025-04-22 14:49:18.353635+03	completed	2025-05-05 13:41:10.759212+03
1003	driver9	2025-04-21 15:35:07.729038+03	2025-04-21 23:05:07.729038+03	completed	2025-05-05 13:41:10.759212+03
1004	driver9	2025-04-21 07:10:36.268331+03	2025-04-21 16:10:36.268331+03	completed	2025-05-05 13:41:10.759212+03
1005	driver9	2025-04-20 05:34:03.604048+03	2025-04-20 14:34:03.604048+03	completed	2025-05-05 13:41:10.759212+03
1006	driver9	2025-04-19 15:32:22.81838+03	2025-04-19 23:02:22.81838+03	completed	2025-05-05 13:41:10.759212+03
1007	driver9	2025-04-19 05:51:10.292862+03	2025-04-19 14:51:10.292862+03	completed	2025-05-05 13:41:10.759212+03
1008	driver9	2025-04-18 15:35:13.233943+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1009	driver9	2025-04-18 06:26:48.516268+03	2025-04-18 15:26:48.516268+03	completed	2025-05-05 13:41:10.759212+03
1010	driver9	2025-04-17 07:23:55.937347+03	2025-04-17 16:23:55.937347+03	completed	2025-05-05 13:41:10.759212+03
1011	driver9	2025-04-16 06:22:00.286435+03	2025-04-16 15:22:00.286435+03	completed	2025-05-05 13:41:10.759212+03
1012	driver9	2025-04-15 15:45:33.731705+03	2025-04-15 23:15:33.731705+03	completed	2025-05-05 13:41:10.759212+03
1013	driver9	2025-04-14 15:19:58.292821+03	2025-04-14 22:49:58.292821+03	completed	2025-05-05 13:41:10.759212+03
1014	driver9	2025-04-14 05:35:11.744476+03	2025-04-14 14:35:11.744476+03	completed	2025-05-05 13:41:10.759212+03
1015	driver9	2025-04-13 06:03:13.519189+03	2025-04-13 15:03:13.519189+03	completed	2025-05-05 13:41:10.759212+03
1016	driver9	2025-04-13 15:28:09.262101+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1017	driver9	2025-04-12 07:20:00.344738+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1018	driver9	2025-04-11 05:58:25.751326+03	2025-04-11 14:58:25.751326+03	completed	2025-05-05 13:41:10.759212+03
1019	driver9	2025-04-10 05:49:38.659601+03	2025-04-10 14:49:38.659601+03	completed	2025-05-05 13:41:10.759212+03
1020	driver9	2025-04-10 06:30:18.668873+03	2025-04-10 15:30:18.668873+03	completed	2025-05-05 13:41:10.759212+03
1021	driver9	2025-04-09 15:41:01.581131+03	2025-04-09 23:11:01.581131+03	completed	2025-05-05 13:41:10.759212+03
1022	driver9	2025-04-09 15:37:49.431238+03	2025-04-09 23:07:49.431238+03	completed	2025-05-05 13:41:10.759212+03
1023	driver9	2025-04-08 07:03:17.806476+03	2025-04-08 16:03:17.806476+03	completed	2025-05-05 13:41:10.759212+03
1024	driver9	2025-04-07 15:32:44.739728+03	2025-04-07 23:02:44.739728+03	completed	2025-05-05 13:41:10.759212+03
1025	driver9	2025-04-06 15:43:42.672549+03	2025-04-06 23:13:42.672549+03	completed	2025-05-05 13:41:10.759212+03
1026	driver9	2025-04-06 07:15:19.287046+03	2025-04-06 16:15:19.287046+03	completed	2025-05-05 13:41:10.759212+03
1027	driver10	2025-05-05 07:02:54.716543+03	2025-05-05 16:02:54.716543+03	completed	2025-05-05 13:41:10.759212+03
1028	driver10	2025-05-05 15:40:00.447548+03	2025-05-05 23:10:00.447548+03	completed	2025-05-05 13:41:10.759212+03
1029	driver10	2025-05-04 15:09:07.129536+03	2025-05-04 22:39:07.129536+03	completed	2025-05-05 13:41:10.759212+03
1030	driver10	2025-05-04 06:43:45.584297+03	2025-05-04 15:43:45.584297+03	completed	2025-05-05 13:41:10.759212+03
1031	driver10	2025-05-03 06:35:39.631936+03	2025-05-03 15:35:39.631936+03	completed	2025-05-05 13:41:10.759212+03
1032	driver10	2025-05-02 05:42:28.210271+03	2025-05-02 14:42:28.210271+03	completed	2025-05-05 13:41:10.759212+03
1033	driver10	2025-05-01 06:05:28.995353+03	2025-05-01 15:05:28.995353+03	completed	2025-05-05 13:41:10.759212+03
1034	driver10	2025-05-01 06:58:55.2743+03	2025-05-01 15:58:55.2743+03	completed	2025-05-05 13:41:10.759212+03
1035	driver10	2025-04-30 15:43:45.477687+03	2025-04-30 23:13:45.477687+03	completed	2025-05-05 13:41:10.759212+03
1036	driver10	2025-04-29 15:01:56.182179+03	2025-04-29 22:31:56.182179+03	completed	2025-05-05 13:41:10.759212+03
1037	driver10	2025-04-28 05:36:29.912812+03	2025-04-28 14:36:29.912812+03	completed	2025-05-05 13:41:10.759212+03
1038	driver10	2025-04-27 15:19:31.01108+03	2025-04-27 22:49:31.01108+03	completed	2025-05-05 13:41:10.759212+03
1039	driver10	2025-04-27 06:56:35.439157+03	2025-04-27 15:56:35.439157+03	completed	2025-05-05 13:41:10.759212+03
1040	driver10	2025-04-26 05:56:16.542191+03	2025-04-26 14:56:16.542191+03	completed	2025-05-05 13:41:10.759212+03
1041	driver10	2025-04-26 15:59:32.108546+03	2025-04-26 23:29:32.108546+03	completed	2025-05-05 13:41:10.759212+03
1042	driver10	2025-04-25 15:32:08.717317+03	2025-04-25 23:02:08.717317+03	completed	2025-05-05 13:41:10.759212+03
1043	driver10	2025-04-24 06:23:48.399823+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1044	driver10	2025-04-23 06:28:47.552347+03	2025-04-23 15:28:47.552347+03	completed	2025-05-05 13:41:10.759212+03
1045	driver10	2025-04-23 15:23:16.088989+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1046	driver10	2025-04-22 15:51:56.607674+03	2025-04-22 23:21:56.607674+03	completed	2025-05-05 13:41:10.759212+03
1047	driver10	2025-04-22 05:32:37.295511+03	2025-04-22 14:32:37.295511+03	completed	2025-05-05 13:41:10.759212+03
1048	driver10	2025-04-21 15:46:01.322393+03	2025-04-21 23:16:01.322393+03	completed	2025-05-05 13:41:10.759212+03
1049	driver10	2025-04-20 15:21:36.688035+03	2025-04-20 22:51:36.688035+03	completed	2025-05-05 13:41:10.759212+03
1050	driver10	2025-04-20 06:50:43.896728+03	2025-04-20 15:50:43.896728+03	completed	2025-05-05 13:41:10.759212+03
1051	driver10	2025-04-19 06:14:02.418443+03	2025-04-19 15:14:02.418443+03	completed	2025-05-05 13:41:10.759212+03
1052	driver10	2025-04-18 06:00:05.95847+03	2025-04-18 15:00:05.95847+03	completed	2025-05-05 13:41:10.759212+03
1053	driver10	2025-04-17 07:09:43.214879+03	2025-04-17 16:09:43.214879+03	completed	2025-05-05 13:41:10.759212+03
1054	driver10	2025-04-17 15:34:06.783765+03	2025-04-17 23:04:06.783765+03	completed	2025-05-05 13:41:10.759212+03
1055	driver10	2025-04-16 07:26:34.950946+03	2025-04-16 16:26:34.950946+03	completed	2025-05-05 13:41:10.759212+03
1056	driver10	2025-04-16 15:50:19.614467+03	2025-04-16 23:20:19.614467+03	completed	2025-05-05 13:41:10.759212+03
1057	driver10	2025-04-15 15:01:41.776455+03	2025-04-15 22:31:41.776455+03	completed	2025-05-05 13:41:10.759212+03
1058	driver10	2025-04-15 15:00:19.660442+03	2025-04-15 22:30:19.660442+03	completed	2025-05-05 13:41:10.759212+03
1059	driver10	2025-04-14 06:30:04.783271+03	2025-04-14 15:30:04.783271+03	completed	2025-05-05 13:41:10.759212+03
1060	driver10	2025-04-13 06:27:13.137038+03	2025-04-13 15:27:13.137038+03	completed	2025-05-05 13:41:10.759212+03
1061	driver10	2025-04-13 15:28:52.884124+03	2025-04-13 22:58:52.884124+03	completed	2025-05-05 13:41:10.759212+03
1062	driver10	2025-04-12 06:13:36.031807+03	2025-04-12 15:13:36.031807+03	completed	2025-05-05 13:41:10.759212+03
1063	driver10	2025-04-11 15:08:22.72523+03	2025-04-11 22:38:22.72523+03	completed	2025-05-05 13:41:10.759212+03
1064	driver10	2025-04-11 06:18:20.734219+03	2025-04-11 15:18:20.734219+03	completed	2025-05-05 13:41:10.759212+03
1065	driver10	2025-04-10 06:10:13.920724+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1066	driver10	2025-04-10 07:02:32.617567+03	2025-04-10 16:02:32.617567+03	completed	2025-05-05 13:41:10.759212+03
1067	driver10	2025-04-09 06:10:08.117804+03	2025-04-09 15:10:08.117804+03	completed	2025-05-05 13:41:10.759212+03
1068	driver10	2025-04-08 06:18:25.282163+03	2025-04-08 15:18:25.282163+03	completed	2025-05-05 13:41:10.759212+03
1069	driver10	2025-04-07 15:32:29.530784+03	2025-04-07 23:02:29.530784+03	completed	2025-05-05 13:41:10.759212+03
1070	driver10	2025-04-06 05:44:31.855647+03	2025-04-06 14:44:31.855647+03	completed	2025-05-05 13:41:10.759212+03
1071	driver10	2025-04-06 15:01:40.10177+03	2025-04-06 22:31:40.10177+03	completed	2025-05-05 13:41:10.759212+03
1072	driver11	2025-05-05 05:55:02.439672+03	2025-05-05 14:55:02.439672+03	completed	2025-05-05 13:41:10.759212+03
1073	driver11	2025-05-04 07:00:27.055453+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1074	driver11	2025-05-03 15:52:15.299632+03	2025-05-03 23:22:15.299632+03	completed	2025-05-05 13:41:10.759212+03
1075	driver11	2025-05-02 15:55:54.785587+03	2025-05-02 23:25:54.785587+03	completed	2025-05-05 13:41:10.759212+03
1076	driver11	2025-05-01 06:01:20.505714+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1077	driver11	2025-05-01 07:24:25.769657+03	2025-05-01 16:24:25.769657+03	completed	2025-05-05 13:41:10.759212+03
1078	driver11	2025-04-30 15:19:55.042488+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1079	driver11	2025-04-29 07:10:12.121475+03	2025-04-29 16:10:12.121475+03	completed	2025-05-05 13:41:10.759212+03
1080	driver11	2025-04-28 05:48:57.900981+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1081	driver11	2025-04-27 15:50:52.568818+03	2025-04-27 23:20:52.568818+03	completed	2025-05-05 13:41:10.759212+03
1082	driver11	2025-04-27 15:15:29.150587+03	2025-04-27 22:45:29.150587+03	completed	2025-05-05 13:41:10.759212+03
1083	driver11	2025-04-26 05:38:04.844902+03	2025-04-26 14:38:04.844902+03	completed	2025-05-05 13:41:10.759212+03
1084	driver11	2025-04-26 07:04:39.881703+03	2025-04-26 16:04:39.881703+03	completed	2025-05-05 13:41:10.759212+03
1085	driver11	2025-04-25 15:39:34.322205+03	2025-04-25 23:09:34.322205+03	completed	2025-05-05 13:41:10.759212+03
1086	driver11	2025-04-24 15:20:16.880528+03	2025-04-24 22:50:16.880528+03	completed	2025-05-05 13:41:10.759212+03
1087	driver11	2025-04-24 05:53:22.91846+03	2025-04-24 14:53:22.91846+03	completed	2025-05-05 13:41:10.759212+03
1088	driver11	2025-04-23 06:38:39.488694+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1089	driver11	2025-04-22 15:09:49.974523+03	2025-04-22 22:39:49.974523+03	completed	2025-05-05 13:41:10.759212+03
1090	driver11	2025-04-21 15:52:26.534877+03	2025-04-21 23:22:26.534877+03	completed	2025-05-05 13:41:10.759212+03
1091	driver11	2025-04-20 15:19:09.880355+03	2025-04-20 22:49:09.880355+03	completed	2025-05-05 13:41:10.759212+03
1092	driver11	2025-04-19 15:19:18.579044+03	2025-04-19 22:49:18.579044+03	completed	2025-05-05 13:41:10.759212+03
1093	driver11	2025-04-18 06:51:09.033396+03	2025-04-18 15:51:09.033396+03	completed	2025-05-05 13:41:10.759212+03
1094	driver11	2025-04-18 06:30:51.532422+03	2025-04-18 15:30:51.532422+03	completed	2025-05-05 13:41:10.759212+03
1095	driver11	2025-04-17 15:27:46.563345+03	2025-04-17 22:57:46.563345+03	completed	2025-05-05 13:41:10.759212+03
1096	driver11	2025-04-17 07:09:44.972318+03	2025-04-17 16:09:44.972318+03	completed	2025-05-05 13:41:10.759212+03
1097	driver11	2025-04-16 15:08:20.1977+03	2025-04-16 22:38:20.1977+03	completed	2025-05-05 13:41:10.759212+03
1098	driver11	2025-04-15 06:41:34.943813+03	2025-04-15 15:41:34.943813+03	completed	2025-05-05 13:41:10.759212+03
1099	driver11	2025-04-15 15:11:51.708443+03	2025-04-15 22:41:51.708443+03	completed	2025-05-05 13:41:10.759212+03
1100	driver11	2025-04-14 06:20:21.380909+03	2025-04-14 15:20:21.380909+03	completed	2025-05-05 13:41:10.759212+03
1101	driver11	2025-04-13 07:13:58.400813+03	2025-04-13 16:13:58.400813+03	completed	2025-05-05 13:41:10.759212+03
1102	driver11	2025-04-12 06:23:07.998779+03	\N	cancelled	2025-05-05 13:41:10.759212+03
1103	driver11	2025-04-12 15:50:48.131723+03	2025-04-12 23:20:48.131723+03	completed	2025-05-05 13:41:10.759212+03
1104	driver11	2025-04-11 06:23:18.481816+03	2025-04-11 15:23:18.481816+03	completed	2025-05-05 13:41:10.759212+03
1105	driver11	2025-04-11 15:01:54.993652+03	2025-04-11 22:31:54.993652+03	completed	2025-05-05 13:41:10.759212+03
1106	driver11	2025-04-10 15:34:47.327223+03	2025-04-10 23:04:47.327223+03	completed	2025-05-05 13:41:10.759212+03
1107	driver11	2025-04-10 05:58:10.237789+03	2025-04-10 14:58:10.237789+03	completed	2025-05-05 13:41:10.759212+03
1108	driver11	2025-04-09 07:01:23.628879+03	2025-04-09 16:01:23.628879+03	completed	2025-05-05 13:41:10.759212+03
1109	driver11	2025-04-09 15:31:55.214711+03	2025-04-09 23:01:55.214711+03	completed	2025-05-05 13:41:10.759212+03
1110	driver11	2025-04-08 15:53:04.652323+03	2025-04-08 23:23:04.652323+03	completed	2025-05-05 13:41:10.759212+03
1111	driver11	2025-04-08 06:51:46.10954+03	2025-04-08 15:51:46.10954+03	completed	2025-05-05 13:41:10.759212+03
1112	driver11	2025-04-07 06:16:47.172831+03	2025-04-07 15:16:47.172831+03	completed	2025-05-05 13:41:10.759212+03
1113	driver11	2025-04-06 15:41:29.128254+03	2025-04-06 23:11:29.128254+03	completed	2025-05-05 13:41:10.759212+03
\.


--
-- Data for Name: financials; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.financials (financial_id, trip_id, revenue, expenses, profit) FROM stdin;
9431	25460	225.00	68.58	156.42
9432	25461	495.00	195.36	299.64
9433	25462	495.00	151.50	343.50
9434	25463	340.00	133.92	206.08
9435	25464	525.00	200.78	324.22
9436	25465	420.00	150.82	269.18
9437	25466	600.00	231.82	368.18
9438	25467	375.00	117.29	257.71
9439	25468	480.00	179.41	300.59
9440	25469	420.00	163.06	256.94
9441	25470	390.00	149.25	240.75
9442	25471	775.00	268.24	506.76
9443	25472	750.00	295.35	454.65
9444	25473	850.00	261.34	588.66
9445	25474	510.00	163.23	346.77
9446	25475	575.00	180.92	394.08
9447	25476	500.00	189.13	310.87
9448	25477	480.00	189.82	290.18
9449	25478	340.00	126.40	213.60
9450	25479	450.00	169.73	280.27
9451	25480	495.00	177.61	317.39
9452	25481	525.00	167.58	357.42
9453	25482	480.00	172.94	307.06
9454	25483	600.00	218.41	381.59
9455	25484	625.00	240.45	384.55
9456	25485	255.00	99.61	155.39
9457	25486	950.00	375.33	574.67
9458	25487	975.00	360.11	614.89
9459	25488	520.00	158.76	361.24
9460	25489	400.00	138.91	261.09
9461	25490	525.00	158.53	366.47
9462	25491	525.00	191.84	333.16
9463	25492	500.00	169.56	330.44
9464	25493	1025.00	403.73	621.27
9465	25494	420.00	127.31	292.69
9466	25495	300.00	94.78	205.22
9467	25496	875.00	289.24	585.76
9468	25497	380.00	136.97	243.03
9469	25498	300.00	93.08	206.92
9470	25499	825.00	295.80	529.20
9471	25500	460.00	168.43	291.57
9472	25501	270.00	86.91	183.09
9473	25502	525.00	170.18	354.82
9474	25503	420.00	153.42	266.58
9475	25504	725.00	280.61	444.39
9476	25505	460.00	155.73	304.27
9477	25506	800.00	301.53	498.47
9478	25507	285.00	89.39	195.61
9479	25508	480.00	153.77	326.23
9480	25509	750.00	238.67	511.33
9481	25510	600.00	214.16	385.84
9482	25511	345.00	117.46	227.54
9483	25512	750.00	230.03	519.97
9484	25513	315.00	125.32	189.68
9485	25514	270.00	84.53	185.47
9486	25515	285.00	92.04	192.96
9487	25516	440.00	141.30	298.70
9488	25517	480.00	185.06	294.94
9489	25518	420.00	162.05	257.95
9490	25519	725.00	236.14	488.86
9491	25520	420.00	163.27	256.73
9492	25521	495.00	178.91	316.09
9493	25522	360.00	125.53	234.47
9494	25523	440.00	134.47	305.53
9495	25524	495.00	163.36	331.64
9496	25525	380.00	140.03	239.97
9497	25526	750.00	286.16	463.84
9498	25527	750.00	262.49	487.51
9499	25528	600.00	209.09	390.91
9500	25529	460.00	181.78	278.22
9501	25530	550.00	166.14	383.86
9502	25531	435.00	141.63	293.37
9503	25532	340.00	107.44	232.56
9504	25533	380.00	133.56	246.44
9505	25534	1025.00	386.13	638.87
9506	25535	850.00	282.28	567.72
9507	25536	1000.00	315.37	684.63
9508	25537	875.00	347.34	527.66
9509	25538	315.00	107.45	207.55
9510	25539	1000.00	374.94	625.06
9511	25540	420.00	131.56	288.44
9512	25541	850.00	328.15	521.85
9513	25542	480.00	190.11	289.89
9514	25543	400.00	148.64	251.36
9515	25544	420.00	156.09	263.91
9516	25545	500.00	193.47	306.53
9517	25546	800.00	279.60	520.40
9518	25547	285.00	92.68	192.32
9519	25548	465.00	185.94	279.06
9520	25549	320.00	97.63	222.37
9521	25550	460.00	172.49	287.51
9522	25551	500.00	197.55	302.45
9523	25552	375.00	129.92	245.08
9524	25553	270.00	105.49	164.51
9525	25554	420.00	149.73	270.27
9526	25555	300.00	118.26	181.74
9527	25556	345.00	129.42	215.58
9528	25557	465.00	161.76	303.24
9529	25558	600.00	208.82	391.18
9530	25559	380.00	151.32	228.68
9531	25560	390.00	142.26	247.74
9532	25561	925.00	364.93	560.07
9533	25562	260.00	94.90	165.10
9534	25563	315.00	106.73	208.27
9535	25564	340.00	132.90	207.10
9536	25565	360.00	125.49	234.51
9537	25566	315.00	104.53	210.47
9538	25567	900.00	344.85	555.15
9539	25568	825.00	251.51	573.49
9540	25569	440.00	138.77	301.23
9541	25570	340.00	116.99	223.01
9542	25571	405.00	160.24	244.76
9543	25572	460.00	146.52	313.48
9544	25573	580.00	201.57	378.43
9545	25574	390.00	125.97	264.03
9546	25575	925.00	338.05	586.95
9547	25576	650.00	245.55	404.45
9548	25577	300.00	94.56	205.44
9549	25578	315.00	111.23	203.77
9550	25579	575.00	207.66	367.34
9551	25580	650.00	208.85	441.15
9552	25581	400.00	155.79	244.21
9553	25582	525.00	206.61	318.39
9554	25583	390.00	134.58	255.42
9555	25584	340.00	114.55	225.45
9556	25585	975.00	300.82	674.18
9557	25586	550.00	215.90	334.10
9558	25587	725.00	285.05	439.95
9559	25588	975.00	305.03	669.97
9560	25589	510.00	192.02	317.98
9561	25590	360.00	139.17	220.83
9562	25591	450.00	144.04	305.96
9563	25592	800.00	278.76	521.24
9564	25593	975.00	389.57	585.43
9565	25594	440.00	150.83	289.17
9566	25595	285.00	94.89	190.11
9567	25596	315.00	102.72	212.28
9568	25597	405.00	129.71	275.29
9569	25598	390.00	122.41	267.59
9570	25599	540.00	168.79	371.21
9571	25600	380.00	136.94	243.06
9572	25601	950.00	367.30	582.70
9573	25602	495.00	181.15	313.85
9574	25603	975.00	325.73	649.27
9575	25604	480.00	163.84	316.16
9576	25605	510.00	162.28	347.72
9577	25606	375.00	122.78	252.22
9578	25607	420.00	155.56	264.44
9579	25608	450.00	159.84	290.16
9580	25609	315.00	125.00	190.00
9581	25610	495.00	167.93	327.07
9582	25611	600.00	233.83	366.17
9583	25612	600.00	200.42	399.58
9584	25613	480.00	166.77	313.23
9585	25614	390.00	140.92	249.08
9586	25615	580.00	186.09	393.91
9587	25616	390.00	142.72	247.28
9588	25617	270.00	102.33	167.67
9589	25618	405.00	124.10	280.90
9590	25619	450.00	179.57	270.43
9591	25620	600.00	224.67	375.33
9592	25621	345.00	136.48	208.52
9593	25622	625.00	204.19	420.81
9594	25623	675.00	215.62	459.38
9595	25624	750.00	249.14	500.86
9596	25625	775.00	263.17	511.83
9597	25626	700.00	259.82	440.18
9598	25627	435.00	130.60	304.40
9599	25628	405.00	152.36	252.64
9600	25629	675.00	224.78	450.22
9601	25630	520.00	171.58	348.42
9602	25631	345.00	130.11	214.89
9603	25632	300.00	97.49	202.51
9604	25633	800.00	262.63	537.37
9605	25634	315.00	107.79	207.21
9606	25635	420.00	151.31	268.69
9607	25636	520.00	162.25	357.75
9608	25637	340.00	114.22	225.78
9609	25638	300.00	106.79	193.21
9610	25639	270.00	87.94	182.06
9611	25640	270.00	96.72	173.28
9612	25641	440.00	155.83	284.17
9613	25642	950.00	318.88	631.12
9614	25643	285.00	88.50	196.50
9615	25644	550.00	207.65	342.35
9616	25645	625.00	195.12	429.88
9617	25646	625.00	248.80	376.20
9618	25647	345.00	119.85	225.15
9619	25648	340.00	108.59	231.41
9620	25649	360.00	117.18	242.82
9621	25650	405.00	131.81	273.19
9622	25651	405.00	125.86	279.14
9623	25652	400.00	159.52	240.48
9624	25653	405.00	154.22	250.78
9625	25654	550.00	210.21	339.79
9626	25655	675.00	234.36	440.64
9627	25656	800.00	284.54	515.46
9628	25657	300.00	91.80	208.20
9629	25658	460.00	162.28	297.72
9630	25659	345.00	126.75	218.25
9631	25660	285.00	91.80	193.20
9632	25661	520.00	174.30	345.70
9633	25662	600.00	204.02	395.98
9634	25663	285.00	91.82	193.18
9635	25664	525.00	175.62	349.38
9636	25665	440.00	175.95	264.05
9637	25666	315.00	121.73	193.27
9638	25667	925.00	285.55	639.45
9639	25668	500.00	154.42	345.58
9640	25669	480.00	153.32	326.68
9641	25670	450.00	136.02	313.98
9642	25671	405.00	155.53	249.47
9643	25672	380.00	144.29	235.71
9644	25673	340.00	122.83	217.17
9645	25674	450.00	160.77	289.23
9646	25675	435.00	168.25	266.75
9647	25676	460.00	142.89	317.11
9648	25677	360.00	116.18	243.82
9649	25678	875.00	294.32	580.68
9650	25679	270.00	105.79	164.21
9651	25680	315.00	106.49	208.51
9652	25681	925.00	298.14	626.86
9653	25682	260.00	90.60	169.40
9654	25683	360.00	110.84	249.16
9655	25684	600.00	187.13	412.87
9656	25685	725.00	277.73	447.27
9657	25686	465.00	170.32	294.68
9658	25687	500.00	197.65	302.35
9659	25688	270.00	100.48	169.52
9660	25689	360.00	136.78	223.22
9661	25690	525.00	174.01	350.99
9662	25691	950.00	296.71	653.29
9663	25692	575.00	202.01	372.99
9664	25693	315.00	118.15	196.85
9665	25694	375.00	123.10	251.90
9666	25695	495.00	149.32	345.68
9667	25696	480.00	150.79	329.21
9668	25697	1025.00	345.17	679.83
9669	25698	360.00	131.05	228.95
9670	25699	380.00	137.98	242.02
9671	25700	450.00	171.01	278.99
9672	25701	875.00	304.16	570.84
9673	25702	600.00	232.63	367.37
9674	25703	480.00	144.35	335.65
9675	25704	650.00	259.42	390.58
9676	25705	465.00	163.70	301.30
9677	25706	315.00	123.37	191.63
9678	25707	420.00	140.07	279.93
9679	25708	330.00	117.61	212.39
9680	25709	465.00	172.82	292.18
9681	25710	520.00	165.59	354.41
9682	25711	380.00	133.93	246.07
9683	25712	825.00	306.51	518.49
9684	25713	775.00	262.01	512.99
9685	25714	550.00	170.72	379.28
9686	25715	270.00	87.00	183.00
9687	25716	600.00	197.26	402.74
9688	25717	435.00	149.56	285.44
9689	25718	1025.00	308.52	716.48
9690	25719	240.00	91.12	148.88
9691	25720	875.00	306.12	568.88
9692	25721	405.00	156.38	248.62
9693	25722	260.00	90.34	169.66
9694	25723	440.00	169.80	270.20
9695	25724	1025.00	327.15	697.85
9696	25725	420.00	126.82	293.18
9697	25726	875.00	295.11	579.89
9698	25727	510.00	187.68	322.32
9699	25728	330.00	117.24	212.76
9700	25729	300.00	98.58	201.42
9701	25730	360.00	115.11	244.89
9702	25731	345.00	129.84	215.16
9703	25732	360.00	141.38	218.62
9704	25733	550.00	209.46	340.54
9705	25734	875.00	321.48	553.52
9706	25735	1000.00	366.27	633.73
9707	25736	625.00	204.99	420.01
9708	25737	725.00	271.78	453.22
9709	25738	750.00	258.49	491.51
9710	25739	320.00	99.62	220.38
9711	25740	375.00	125.92	249.08
9712	25741	420.00	156.05	263.95
9713	25742	480.00	171.97	308.03
9714	25743	525.00	160.69	364.31
9715	25744	480.00	170.24	309.76
9716	25745	345.00	117.81	227.19
9717	25746	420.00	126.03	293.97
9718	25747	495.00	151.34	343.66
9719	25748	625.00	246.52	378.48
9720	25749	380.00	121.63	258.37
9721	25750	520.00	163.72	356.28
9722	25751	450.00	161.75	288.25
9723	25752	480.00	149.52	330.48
9724	25753	400.00	124.84	275.16
9725	25754	1000.00	355.30	644.70
9726	25755	525.00	198.83	326.17
9727	25756	875.00	320.14	554.86
9728	25757	300.00	92.59	207.41
9729	25758	465.00	163.41	301.59
9730	25759	1025.00	371.19	653.81
9731	25760	360.00	117.71	242.29
9732	25761	405.00	149.70	255.30
9733	25762	450.00	148.96	301.04
9734	25763	875.00	265.41	609.59
9735	25764	580.00	181.41	398.59
9736	25765	405.00	140.64	264.36
9737	25766	300.00	92.52	207.48
9738	25767	510.00	178.96	331.04
9739	25768	420.00	140.13	279.87
9740	25769	360.00	137.94	222.06
9741	25770	360.00	110.39	249.61
9742	25771	260.00	97.90	162.10
9743	25772	320.00	124.69	195.31
9744	25773	800.00	260.91	539.09
9745	25774	495.00	160.57	334.43
9746	25775	560.00	195.22	364.78
9747	25776	360.00	110.66	249.34
9748	25777	315.00	110.88	204.12
9749	25778	330.00	129.02	200.98
9750	25779	525.00	160.25	364.75
9751	25780	360.00	122.21	237.79
9752	25781	420.00	145.70	274.30
9753	25782	600.00	193.72	406.28
9754	25783	300.00	116.07	183.93
9755	25784	495.00	183.12	311.88
9756	25785	420.00	144.43	275.57
9757	25786	500.00	169.31	330.69
9758	25787	460.00	150.46	309.54
9759	25788	400.00	154.89	245.11
9760	25789	390.00	118.31	271.69
9761	25790	480.00	154.34	325.66
9762	25791	480.00	173.62	306.38
9763	25792	435.00	164.94	270.06
9764	25793	345.00	136.99	208.01
9765	25794	435.00	138.95	296.05
9766	25795	450.00	140.21	309.79
9767	25796	480.00	149.96	330.04
9768	25797	270.00	84.74	185.26
9769	25798	315.00	116.14	198.86
9770	25799	450.00	144.85	305.15
9771	25800	480.00	164.12	315.88
9772	25801	280.00	98.30	181.70
9773	25802	420.00	129.83	290.17
9774	25803	750.00	259.34	490.66
9775	25804	255.00	100.75	154.25
9776	25805	550.00	182.21	367.79
9777	25806	340.00	112.32	227.68
9778	25807	725.00	234.20	490.80
9779	25808	405.00	134.44	270.56
9780	25809	540.00	190.86	349.14
9781	25810	360.00	112.07	247.93
9782	25811	580.00	175.39	404.61
9783	25812	420.00	126.07	293.93
9784	25813	850.00	313.22	536.78
9785	25814	400.00	136.21	263.79
9786	25815	550.00	173.90	376.10
9787	25816	495.00	177.59	317.41
9788	25817	270.00	98.63	171.37
9789	25818	465.00	153.55	311.45
9790	25819	300.00	97.27	202.73
9791	25820	465.00	178.13	286.87
9792	25821	285.00	87.22	197.78
9793	25822	400.00	139.60	260.40
9794	25823	465.00	168.33	296.67
9795	25824	375.00	143.99	231.01
9796	25825	925.00	345.61	579.39
9797	25826	405.00	131.73	273.27
9798	25827	750.00	230.82	519.18
9799	25828	320.00	116.63	203.37
9800	25829	875.00	307.75	567.25
9801	25830	500.00	167.63	332.37
9802	25831	700.00	277.83	422.17
9803	25832	875.00	344.49	530.51
9804	25833	520.00	159.21	360.79
9805	25834	330.00	117.63	212.37
9806	25835	1000.00	310.19	689.81
9807	25836	495.00	164.50	330.50
9808	25837	460.00	158.71	301.29
9809	25838	330.00	125.60	204.40
9810	25839	360.00	138.31	221.69
9811	25840	360.00	113.46	246.54
9812	25841	540.00	214.06	325.94
9813	25842	225.00	67.75	157.25
9814	25843	405.00	137.43	267.57
9815	25844	420.00	155.40	264.60
9816	25845	340.00	133.50	206.50
9817	25846	320.00	122.90	197.10
9818	25847	300.00	111.66	188.34
9819	25848	520.00	164.90	355.10
9820	25849	300.00	112.63	187.37
9821	25850	405.00	143.47	261.53
9822	25851	420.00	134.56	285.44
9823	25852	1025.00	377.80	647.20
9824	25853	580.00	206.49	373.51
9825	25854	975.00	367.90	607.10
9826	25855	495.00	178.62	316.38
9827	25856	435.00	151.43	283.57
9828	25857	375.00	140.52	234.48
9829	25858	340.00	118.08	221.92
9830	25859	650.00	257.03	392.97
9831	25860	650.00	255.35	394.65
9832	25861	975.00	308.06	666.94
9833	25862	800.00	306.64	493.36
9834	25863	850.00	280.73	569.27
9835	25864	700.00	224.68	475.32
9836	25865	775.00	283.11	491.89
9837	25866	465.00	171.40	293.60
9838	25867	480.00	162.26	317.74
9839	25868	800.00	278.10	521.90
9840	25869	330.00	106.99	223.01
9841	25870	450.00	179.49	270.51
9842	25871	925.00	283.35	641.65
9843	25872	450.00	143.13	306.87
9844	25873	280.00	97.78	182.22
9845	25874	380.00	133.75	246.25
9846	25875	480.00	182.29	297.71
9847	25876	525.00	187.85	337.15
9848	25877	380.00	135.80	244.20
9849	25878	330.00	101.17	228.83
9850	25879	420.00	160.44	259.56
9851	25880	400.00	158.65	241.35
9852	25881	300.00	94.01	205.99
9853	25882	375.00	114.51	260.49
9854	25883	500.00	183.74	316.26
9855	25884	450.00	178.47	271.53
9856	25885	625.00	193.70	431.30
9857	25886	405.00	129.38	275.62
9858	25887	330.00	121.33	208.67
9859	25888	280.00	91.24	188.76
9860	25889	800.00	305.66	494.34
9861	25890	300.00	94.95	205.05
9862	25891	775.00	302.15	472.85
9863	25892	225.00	86.68	138.32
9864	25893	300.00	92.15	207.85
9865	25894	580.00	176.91	403.09
9866	25895	400.00	131.48	268.52
9867	25896	450.00	142.24	307.76
9868	25897	510.00	174.96	335.04
9869	25898	300.00	100.35	199.65
9870	25899	400.00	126.33	273.67
9871	25900	450.00	168.94	281.06
9872	25901	405.00	136.74	268.26
9873	25902	520.00	194.08	325.92
9874	25903	320.00	97.29	222.71
9875	25904	480.00	190.10	289.90
9876	25905	260.00	102.90	157.10
9877	25906	315.00	124.79	190.21
9878	25907	255.00	92.68	162.32
9879	25908	625.00	226.70	398.30
9880	25909	465.00	183.42	281.58
9881	25910	300.00	109.16	190.84
9882	25911	775.00	234.04	540.96
9883	25912	510.00	195.82	314.18
9884	25913	975.00	297.63	677.37
9885	25914	950.00	351.13	598.87
9886	25915	360.00	119.15	240.85
9887	25916	345.00	127.62	217.38
9888	25917	420.00	134.71	285.29
9889	25918	440.00	158.69	281.31
9890	25919	540.00	197.02	342.98
9891	25920	540.00	175.47	364.53
9892	25921	975.00	334.93	640.07
9893	25922	330.00	120.48	209.52
9894	25923	270.00	86.05	183.95
9895	25924	420.00	146.13	273.87
9896	25925	420.00	135.30	284.70
9897	25926	975.00	309.31	665.69
9898	25927	495.00	177.42	317.58
9899	25928	270.00	91.66	178.34
9900	25929	375.00	138.43	236.57
9901	25930	340.00	114.18	225.82
9902	25931	360.00	124.40	235.60
9903	25932	580.00	187.08	392.92
9904	25933	345.00	119.19	225.81
9905	25934	270.00	97.02	172.98
9906	25935	420.00	158.34	261.66
9907	25936	575.00	198.37	376.63
9908	25937	510.00	172.10	337.90
9909	25938	1000.00	309.71	690.29
9910	25939	575.00	226.31	348.69
9911	25940	625.00	212.20	412.80
9912	25941	375.00	140.57	234.43
9913	25942	420.00	154.63	265.37
9914	25943	900.00	323.02	576.98
9915	25944	480.00	163.62	316.38
9916	25945	500.00	156.65	343.35
9917	25946	420.00	130.69	289.31
9918	25947	510.00	194.59	315.41
9919	25948	580.00	205.89	374.11
9920	25949	390.00	151.99	238.01
9921	25950	270.00	102.04	167.96
9922	25951	405.00	160.04	244.96
9923	25952	345.00	107.89	237.11
9924	25953	400.00	133.76	266.24
9925	25954	300.00	98.28	201.72
9926	25955	330.00	120.99	209.01
9927	25956	390.00	124.62	265.38
9928	25957	465.00	183.41	281.59
9929	25958	420.00	135.30	284.70
9930	25959	675.00	214.88	460.12
9931	25960	550.00	186.20	363.80
9932	25961	375.00	149.01	225.99
9933	25962	700.00	218.58	481.42
9934	25963	1025.00	314.92	710.08
9935	25964	270.00	106.79	163.21
9936	25965	400.00	145.90	254.10
9937	25966	825.00	276.95	548.05
9938	25967	775.00	259.13	515.87
9939	25968	400.00	144.11	255.89
9940	25969	510.00	166.17	343.83
9941	25970	480.00	167.08	312.92
9942	25971	375.00	124.53	250.47
9943	25972	600.00	183.77	416.23
9944	25973	330.00	124.38	205.62
9945	25974	450.00	155.05	294.95
9946	25975	580.00	209.45	370.55
9947	25976	825.00	315.48	509.52
9948	25977	315.00	101.09	213.91
9949	25978	330.00	104.18	225.82
9950	25979	480.00	178.43	301.57
9951	25980	775.00	306.37	468.63
9952	25981	320.00	96.51	223.49
9953	25982	440.00	166.51	273.49
9954	25983	465.00	179.46	285.54
9955	25984	480.00	172.32	307.68
9956	25985	270.00	103.86	166.14
9957	25986	460.00	151.57	308.43
9958	25987	390.00	153.76	236.24
9959	25988	950.00	340.76	609.24
9960	25989	525.00	199.03	325.97
9961	25990	580.00	191.58	388.42
9962	25991	675.00	259.85	415.15
9963	25992	575.00	182.45	392.55
9964	25993	420.00	128.19	291.81
9965	25994	480.00	170.42	309.58
9966	25995	360.00	113.70	246.30
9967	25996	390.00	125.97	264.03
9968	25997	375.00	144.99	230.01
9969	25998	925.00	350.84	574.16
9970	25999	850.00	262.09	587.91
9971	26000	495.00	161.30	333.70
9972	26001	510.00	180.17	329.83
9973	26002	320.00	97.09	222.91
9974	26003	480.00	161.11	318.89
9975	26004	495.00	164.15	330.85
9976	26005	460.00	171.26	288.74
9977	26006	525.00	206.61	318.39
9978	26007	340.00	132.79	207.21
9979	26008	600.00	181.76	418.24
9980	26009	300.00	97.25	202.75
9981	26010	525.00	175.56	349.44
9982	26011	360.00	119.18	240.82
9983	26012	420.00	139.90	280.10
9984	26013	525.00	158.41	366.59
9985	26014	390.00	129.32	260.68
9986	26015	800.00	280.56	519.44
9987	26016	750.00	289.85	460.15
9988	26017	285.00	92.63	192.37
9989	26018	340.00	126.67	213.33
9990	26019	435.00	142.09	292.91
9991	26020	525.00	180.93	344.07
9992	26021	510.00	184.61	325.39
9993	26022	975.00	365.67	609.33
9994	26023	460.00	159.59	300.41
9995	26024	320.00	110.34	209.66
9996	26025	280.00	92.89	187.11
9997	26026	495.00	182.69	312.31
9998	26027	440.00	154.91	285.09
9999	26028	450.00	179.67	270.33
10000	26029	435.00	172.62	262.38
10001	26030	500.00	168.33	331.67
10002	26031	320.00	101.58	218.42
10003	26032	420.00	150.71	269.29
10004	26033	800.00	303.12	496.88
10005	26034	850.00	299.24	550.76
10006	26035	525.00	163.66	361.34
10007	26036	390.00	144.86	245.14
10008	26037	280.00	95.44	184.56
10009	26038	775.00	266.77	508.23
10010	26039	420.00	144.35	275.65
10011	26040	420.00	154.63	265.37
10012	26041	480.00	151.76	328.24
10013	26042	495.00	174.69	320.31
10014	26043	345.00	121.17	223.83
10015	26044	775.00	275.38	499.62
10016	26045	300.00	100.41	199.59
10017	26046	390.00	121.60	268.40
10018	26047	500.00	150.53	349.47
10019	26048	775.00	243.71	531.29
10020	26049	315.00	97.39	217.61
10021	26050	525.00	174.85	350.15
10022	26051	420.00	138.62	281.38
10023	26052	875.00	335.46	539.54
10024	26053	850.00	319.30	530.70
10025	26054	460.00	142.29	317.71
10026	26055	580.00	220.84	359.16
10027	26056	390.00	135.09	254.91
10028	26057	500.00	196.85	303.15
10029	26058	280.00	106.97	173.03
10030	26059	340.00	132.76	207.24
10031	26060	700.00	230.27	469.73
10032	26061	525.00	170.77	354.23
10033	26062	300.00	90.52	209.48
10034	26063	495.00	171.66	323.34
10035	26064	750.00	284.53	465.47
10036	26065	255.00	98.48	156.52
10037	26066	580.00	199.57	380.43
10038	26067	825.00	308.61	516.39
10039	26068	420.00	143.74	276.26
10040	26069	375.00	117.63	257.37
10041	26070	390.00	150.46	239.54
10042	26071	285.00	102.91	182.09
10043	26072	405.00	145.53	259.47
10044	26073	345.00	108.68	236.32
10045	26074	510.00	196.97	313.03
10046	26075	575.00	179.59	395.41
10047	26076	400.00	123.45	276.55
10048	26077	650.00	202.86	447.14
10049	26078	500.00	169.62	330.38
10050	26079	495.00	180.53	314.47
10051	26080	750.00	232.97	517.03
10052	26081	875.00	305.51	569.49
10053	26082	340.00	113.03	226.97
10054	26083	320.00	114.97	205.03
10055	26084	875.00	325.90	549.10
10056	26085	390.00	123.94	266.06
10057	26086	875.00	331.51	543.49
10058	26087	650.00	229.68	420.32
10059	26088	850.00	336.60	513.40
10060	26089	330.00	122.37	207.63
10061	26090	440.00	138.09	301.91
10062	26091	345.00	134.35	210.65
10063	26092	440.00	137.91	302.09
10064	26093	280.00	101.10	178.90
10065	26094	360.00	111.35	248.65
10066	26095	320.00	108.79	211.21
10067	26096	360.00	109.70	250.30
10068	26097	405.00	145.58	259.42
10069	26098	390.00	122.64	267.36
10070	26099	330.00	129.62	200.38
10071	26100	465.00	141.24	323.76
10072	26101	875.00	279.52	595.48
10073	26102	285.00	104.70	180.30
10074	26103	285.00	109.44	175.56
10075	26104	360.00	132.56	227.44
10076	26105	300.00	91.05	208.95
10077	26106	345.00	106.91	238.09
10078	26107	280.00	99.84	180.16
10079	26108	650.00	214.73	435.27
10080	26109	510.00	176.05	333.95
10081	26110	345.00	130.49	214.51
10082	26111	405.00	143.25	261.75
10083	26112	775.00	235.91	539.09
10084	26113	500.00	193.46	306.54
10085	26114	315.00	114.95	200.05
10086	26115	500.00	157.33	342.67
10087	26116	500.00	175.40	324.60
10088	26117	345.00	109.91	235.09
10089	26118	480.00	174.57	305.43
10090	26119	1025.00	356.47	668.53
10091	26120	450.00	139.46	310.54
10092	26121	875.00	330.55	544.45
10093	26122	420.00	159.65	260.35
10094	26123	625.00	216.22	408.78
10095	26124	460.00	141.05	318.95
10096	26125	875.00	292.36	582.64
10097	26126	925.00	287.75	637.25
10098	26127	825.00	280.58	544.42
10099	26128	330.00	111.24	218.76
10100	26129	700.00	272.50	427.50
10101	26130	330.00	100.16	229.84
10102	26131	320.00	122.72	197.28
10103	26132	875.00	340.05	534.95
10104	26133	400.00	137.15	262.85
10105	26134	285.00	99.26	185.74
10106	26135	525.00	201.95	323.05
10107	26136	510.00	185.01	324.99
10108	26137	550.00	176.53	373.47
10109	26138	440.00	163.76	276.24
10110	26139	580.00	226.44	353.56
10111	26140	300.00	115.79	184.21
10112	26141	320.00	115.37	204.63
10113	26142	1000.00	316.24	683.76
10114	26143	330.00	121.28	208.72
10115	26144	285.00	113.65	171.35
10116	26145	540.00	201.24	338.76
10117	26146	420.00	157.46	262.54
10118	26147	320.00	116.15	203.85
10119	26148	525.00	157.55	367.45
10120	26149	625.00	224.39	400.61
10121	26150	375.00	145.89	229.11
10122	26151	1000.00	337.22	662.78
10123	26152	300.00	107.61	192.39
10124	26153	300.00	113.12	186.88
10125	26154	380.00	114.01	265.99
10126	26155	360.00	122.01	237.99
10127	26156	280.00	84.69	195.31
10128	26157	750.00	250.25	499.75
10129	26158	950.00	355.56	594.44
10130	26159	375.00	149.92	225.08
10131	26160	375.00	148.89	226.11
10132	26161	360.00	133.53	226.47
10133	26162	255.00	88.14	166.86
10134	26163	700.00	255.16	444.84
10135	26164	315.00	99.83	215.17
10136	26165	495.00	155.73	339.27
10137	26166	270.00	82.06	187.94
10138	26167	375.00	148.34	226.66
10139	26168	375.00	130.24	244.76
10140	26169	400.00	125.26	274.74
10141	26170	435.00	142.49	292.51
10142	26171	315.00	108.51	206.49
10143	26172	560.00	218.58	341.42
10144	26173	390.00	123.07	266.93
10145	26174	500.00	174.50	325.50
10146	26175	775.00	306.42	468.58
10147	26176	440.00	160.78	279.22
10148	26177	500.00	175.37	324.63
10149	26178	340.00	116.16	223.84
10150	26179	315.00	104.17	210.83
10151	26180	400.00	122.32	277.68
10152	26181	260.00	90.46	169.54
10153	26182	480.00	173.39	306.61
10154	26183	400.00	159.27	240.73
10155	26184	330.00	119.35	210.65
10156	26185	900.00	286.21	613.79
10157	26186	390.00	129.12	260.88
10158	26187	480.00	165.65	314.35
10159	26188	360.00	117.02	242.98
10160	26189	420.00	136.88	283.12
10161	26190	340.00	121.36	218.64
10162	26191	375.00	144.86	230.14
10163	26192	520.00	192.26	327.74
10164	26193	450.00	135.58	314.42
10165	26194	875.00	330.43	544.57
10166	26195	950.00	344.53	605.47
10167	26196	550.00	172.62	377.38
10168	26197	255.00	78.21	176.79
10169	26198	525.00	205.85	319.15
10170	26199	380.00	133.12	246.88
10171	26200	520.00	204.40	315.60
10172	26201	360.00	115.16	244.84
10173	26202	510.00	162.85	347.15
10174	26203	340.00	129.89	210.11
10175	26204	1000.00	338.15	661.85
10176	26205	320.00	97.81	222.19
10177	26206	925.00	347.01	577.99
10178	26207	510.00	173.61	336.39
10179	26208	270.00	84.64	185.36
10180	26209	480.00	185.98	294.02
10181	26210	950.00	304.61	645.39
10182	26211	360.00	136.23	223.77
10183	26212	360.00	130.19	229.81
10184	26213	465.00	151.38	313.62
10185	26214	750.00	225.19	524.81
10186	26215	465.00	183.72	281.28
10187	26216	925.00	298.10	626.90
10188	26217	1000.00	320.51	679.49
10189	26218	345.00	119.40	225.60
10190	26219	400.00	144.62	255.38
10191	26220	460.00	179.58	280.42
10192	26221	975.00	358.60	616.40
10193	26222	390.00	122.40	267.60
10194	26223	315.00	122.92	192.08
10195	26224	330.00	119.30	210.70
10196	26225	500.00	162.56	337.44
10197	26226	525.00	168.21	356.79
10198	26227	435.00	145.62	289.38
10199	26228	480.00	186.58	293.42
10200	26229	950.00	376.97	573.03
10201	26230	420.00	127.57	292.43
10202	26231	925.00	316.49	608.51
10203	26232	600.00	215.39	384.61
10204	26233	285.00	101.64	183.36
10205	26234	600.00	236.17	363.83
10206	26235	560.00	206.22	353.78
10207	26236	900.00	273.95	626.05
10208	26237	340.00	111.64	228.36
10209	26238	975.00	354.39	620.61
10210	26239	675.00	225.19	449.81
10211	26240	450.00	158.90	291.10
10212	26241	450.00	148.02	301.98
10213	26242	405.00	124.51	280.49
10214	26243	480.00	173.76	306.24
10215	26244	405.00	133.49	271.51
10216	26245	270.00	103.66	166.34
10217	26246	340.00	115.45	224.55
10218	26247	315.00	121.76	193.24
10219	26248	925.00	323.67	601.33
10220	26249	480.00	160.10	319.90
10221	26250	825.00	266.16	558.84
10222	26251	875.00	262.57	612.43
10223	26252	975.00	377.87	597.13
10224	26253	270.00	84.67	185.33
10225	26254	600.00	190.81	409.19
10226	26255	675.00	265.46	409.54
10227	26256	510.00	180.87	329.13
10228	26257	330.00	111.05	218.95
10229	26258	390.00	139.72	250.28
10230	26259	375.00	143.27	231.73
10231	26260	420.00	131.19	288.81
10232	26261	575.00	187.09	387.91
10233	26262	285.00	108.85	176.15
10234	26263	510.00	189.49	320.51
10235	26264	240.00	88.55	151.45
10236	26265	440.00	147.69	292.31
10237	26266	440.00	141.60	298.40
10238	26267	700.00	232.51	467.49
10239	26268	375.00	114.87	260.13
10240	26269	775.00	256.31	518.69
10241	26270	435.00	154.33	280.67
10242	26271	480.00	182.13	297.87
10243	26272	300.00	93.79	206.21
10244	26273	420.00	126.83	293.17
10245	26274	480.00	154.36	325.64
10246	26275	850.00	276.27	573.73
10247	26276	600.00	226.17	373.83
10248	26277	1025.00	326.46	698.54
10249	26278	510.00	180.88	329.12
10250	26279	460.00	160.57	299.43
10251	26280	330.00	116.20	213.80
10252	26281	420.00	154.55	265.45
10253	26282	480.00	147.48	332.52
10254	26283	435.00	137.97	297.03
10255	26284	300.00	108.42	191.58
10256	26285	525.00	171.27	353.73
10257	26286	340.00	114.64	225.36
10258	26287	525.00	190.88	334.12
10259	26288	320.00	119.46	200.54
10260	26289	800.00	264.67	535.33
10261	26290	900.00	321.18	578.82
10262	26291	975.00	383.44	591.56
10263	26292	525.00	190.64	334.36
10264	26293	360.00	124.33	235.67
10265	26294	850.00	288.74	561.26
10266	26295	480.00	170.86	309.14
10267	26296	360.00	126.63	233.37
10268	26297	525.00	175.02	349.98
10269	26298	510.00	196.89	313.11
10270	26299	340.00	130.29	209.71
10271	26300	380.00	143.80	236.20
10272	26301	390.00	143.83	246.17
10273	26302	775.00	279.71	495.29
10274	26303	400.00	130.34	269.66
10275	26304	480.00	180.08	299.92
10276	26305	1000.00	338.02	661.98
10277	26306	360.00	122.74	237.26
10278	26307	875.00	335.93	539.07
10279	26308	300.00	102.28	197.72
10280	26309	450.00	154.56	295.44
10281	26310	435.00	169.87	265.13
10282	26311	285.00	98.22	186.78
10283	26312	280.00	97.86	182.14
10284	26313	750.00	294.25	455.75
10285	26314	560.00	212.79	347.21
10286	26315	950.00	364.55	585.45
10287	26316	300.00	111.14	188.86
10288	26317	315.00	115.02	199.98
10289	26318	340.00	120.26	219.74
10290	26319	480.00	159.53	320.47
10291	26320	300.00	96.38	203.62
10292	26321	315.00	114.61	200.39
10293	26322	345.00	123.89	221.11
10294	26323	975.00	324.17	650.83
10295	26324	340.00	102.04	237.96
10296	26325	340.00	125.80	214.20
10297	26326	500.00	181.28	318.72
10298	26327	600.00	228.26	371.74
10299	26328	900.00	294.81	605.19
10300	26329	525.00	164.25	360.75
10301	26330	405.00	123.81	281.19
10302	26331	420.00	162.70	257.30
10303	26332	405.00	125.52	279.48
10304	26333	750.00	294.99	455.01
10305	26334	380.00	143.56	236.44
10306	26335	480.00	156.67	323.33
10307	26336	750.00	229.19	520.81
10308	26337	345.00	122.70	222.30
10309	26338	420.00	138.38	281.62
10310	26339	400.00	144.43	255.57
10311	26340	340.00	123.75	216.25
10312	26341	510.00	201.32	308.68
10313	26342	600.00	221.23	378.77
10314	26343	435.00	145.53	289.47
10315	26344	650.00	232.71	417.29
10316	26345	800.00	263.00	537.00
10317	26346	360.00	142.66	217.34
10318	26347	495.00	155.82	339.18
10319	26348	900.00	285.02	614.98
10320	26349	525.00	160.12	364.88
10321	26350	300.00	111.17	188.83
10322	26351	975.00	318.52	656.48
10323	26352	600.00	196.89	403.11
10324	26353	380.00	146.47	233.53
10325	26354	440.00	159.57	280.43
10326	26355	390.00	148.59	241.41
10327	26356	285.00	113.69	171.31
10328	26357	575.00	200.24	374.76
10329	26358	525.00	170.83	354.17
10330	26359	540.00	173.59	366.41
10331	26360	375.00	148.15	226.85
10332	26361	750.00	253.62	496.38
10333	26362	525.00	203.89	321.11
10334	26363	875.00	273.57	601.43
10335	26364	330.00	109.58	220.42
10336	26365	500.00	159.53	340.47
10337	26366	540.00	192.72	347.28
10338	26367	345.00	119.25	225.75
10339	26368	375.00	125.19	249.81
10340	26369	525.00	157.70	367.30
10341	26370	495.00	173.65	321.35
10342	26371	600.00	227.49	372.51
10343	26372	525.00	167.57	357.43
10344	26373	435.00	167.86	267.14
10345	26374	725.00	260.00	465.00
10346	26375	450.00	174.99	275.01
10347	26376	750.00	261.65	488.35
10348	26377	360.00	125.63	234.37
10349	26378	825.00	265.42	559.58
10350	26379	500.00	154.52	345.48
10351	26380	360.00	142.84	217.16
10352	26381	510.00	153.92	356.08
10353	26382	360.00	124.40	235.60
10354	26383	300.00	112.04	187.96
10355	26384	510.00	186.66	323.34
10356	26385	1000.00	378.82	621.18
10357	26386	345.00	106.82	238.18
10358	26387	285.00	100.34	184.66
10359	26388	750.00	279.62	470.38
10360	26389	330.00	130.51	199.49
10361	26390	300.00	100.77	199.23
10362	26391	420.00	156.01	263.99
10363	26392	330.00	110.22	219.78
10364	26393	375.00	118.83	256.17
10365	26394	375.00	115.41	259.59
10366	26395	360.00	126.25	233.75
10367	26396	520.00	204.68	315.32
10368	26397	390.00	118.43	271.57
10369	26398	625.00	210.37	414.63
10370	26399	525.00	158.47	366.53
10371	26400	405.00	147.58	257.42
10372	26401	460.00	143.27	316.73
10373	26402	525.00	169.42	355.58
10374	26403	460.00	166.80	293.20
10375	26404	510.00	192.76	317.24
10376	26405	330.00	119.08	210.92
10377	26406	390.00	154.66	235.34
10378	26407	900.00	330.89	569.11
10379	26408	400.00	152.58	247.42
10380	26409	495.00	188.99	306.01
10381	26410	1025.00	355.04	669.96
10382	26411	480.00	149.13	330.87
10383	26412	340.00	113.40	226.60
10384	26413	625.00	222.44	402.56
10385	26414	1025.00	395.28	629.72
10386	26415	440.00	156.89	283.11
10387	26416	390.00	147.13	242.87
10388	26417	900.00	284.50	615.50
10389	26418	510.00	174.28	335.72
10390	26419	460.00	139.12	320.88
10391	26420	465.00	176.46	288.54
10392	26421	360.00	114.40	245.60
10393	26422	315.00	118.60	196.40
10394	26423	320.00	105.68	214.32
10395	26424	480.00	179.06	300.94
10396	26425	1025.00	328.92	696.08
10397	26426	575.00	223.08	351.92
10398	26427	750.00	291.21	458.79
10399	26428	420.00	139.10	280.90
10400	26429	975.00	317.66	657.34
10401	26430	465.00	164.14	300.86
10402	26431	495.00	179.40	315.60
10403	26432	285.00	110.07	174.93
10404	26433	465.00	143.98	321.02
10405	26434	440.00	149.43	290.57
10406	26435	435.00	139.80	295.20
10407	26436	345.00	116.93	228.07
10408	26437	360.00	137.45	222.55
10409	26438	800.00	274.66	525.34
10410	26439	330.00	118.66	211.34
10411	26440	575.00	176.65	398.35
10412	26441	340.00	113.44	226.56
10413	26442	375.00	142.98	232.02
10414	26443	950.00	334.02	615.98
10415	26444	925.00	346.42	578.58
10416	26445	480.00	191.18	288.82
10417	26446	460.00	178.51	281.49
10418	26447	540.00	178.89	361.11
10419	26448	450.00	149.38	300.62
10420	26449	375.00	147.32	227.68
10421	26450	390.00	121.99	268.01
10422	26451	390.00	131.99	258.01
10423	26452	260.00	89.22	170.78
10424	26453	480.00	190.85	289.15
10425	26454	525.00	166.67	358.33
10426	26455	925.00	362.17	562.83
10427	26456	560.00	189.75	370.25
10428	26457	340.00	127.77	212.23
10429	26458	400.00	127.81	272.19
10430	26459	320.00	105.62	214.38
10431	26460	525.00	160.25	364.75
10432	26461	510.00	158.66	351.34
10433	26462	270.00	104.73	165.27
10434	26463	480.00	154.78	325.22
10435	26464	800.00	266.29	533.71
10436	26465	345.00	130.54	214.46
10437	26466	330.00	117.37	212.63
10438	26467	300.00	109.89	190.11
10439	26468	510.00	182.82	327.18
10440	26469	1000.00	337.91	662.09
10441	26470	260.00	87.80	172.20
10442	26471	580.00	177.96	402.04
10443	26472	330.00	123.88	206.12
10444	26473	625.00	239.67	385.33
10445	26474	435.00	154.37	280.63
10446	26475	315.00	108.02	206.98
10447	26476	315.00	117.82	197.18
10448	26477	420.00	141.83	278.17
10449	26478	650.00	216.12	433.88
10450	26479	300.00	91.95	208.05
10451	26480	520.00	176.97	343.03
10452	26481	420.00	154.85	265.15
10453	26482	320.00	124.47	195.53
10454	26483	625.00	243.91	381.09
10455	26484	1025.00	363.13	661.87
10456	26485	440.00	163.30	276.70
10457	26486	825.00	270.42	554.58
10458	26487	435.00	168.99	266.01
10459	26488	500.00	194.10	305.90
10460	26489	450.00	155.87	294.13
10461	26490	1025.00	314.51	710.49
10462	26491	480.00	155.13	324.87
10463	26492	270.00	100.32	169.68
10464	26493	550.00	177.85	372.15
10465	26494	390.00	147.51	242.49
10466	26495	500.00	162.00	338.00
10467	26496	460.00	143.79	316.21
10468	26497	345.00	128.19	216.81
10469	26498	260.00	82.24	177.76
10470	26499	435.00	133.39	301.61
10471	26500	850.00	295.40	554.60
10472	26501	825.00	275.82	549.18
10473	26502	450.00	147.90	302.10
10474	26503	260.00	85.82	174.18
10475	26504	405.00	137.86	267.14
10476	26505	950.00	340.25	609.75
10477	26506	675.00	234.44	440.56
10478	26507	345.00	104.65	240.35
10479	26508	800.00	299.58	500.42
10480	26509	900.00	333.08	566.92
10481	26510	405.00	127.58	277.42
10482	26511	360.00	111.42	248.58
10483	26512	420.00	129.69	290.31
10484	26513	375.00	121.75	253.25
10485	26514	625.00	194.31	430.69
10486	26515	925.00	336.53	588.47
10487	26516	315.00	114.55	200.45
10488	26517	330.00	108.55	221.45
10489	26518	400.00	126.91	273.09
10490	26519	380.00	138.96	241.04
10491	26520	390.00	136.56	253.44
10492	26521	520.00	176.94	343.06
10493	26522	580.00	179.80	400.20
10494	26523	500.00	151.64	348.36
10495	26524	825.00	289.91	535.09
10496	26525	360.00	111.52	248.48
10497	26526	510.00	163.90	346.10
10498	26527	375.00	140.79	234.21
10499	26528	360.00	111.65	248.35
10500	26529	260.00	103.44	156.56
10501	26530	345.00	123.11	221.89
10502	26531	525.00	167.83	357.17
10503	26532	540.00	190.72	349.28
10504	26533	255.00	86.59	168.41
10505	26534	540.00	182.59	357.41
10506	26535	1000.00	367.98	632.02
10507	26536	450.00	169.72	280.28
10508	26537	420.00	146.28	273.72
10509	26538	420.00	126.35	293.65
10510	26539	480.00	160.98	319.02
10511	26540	300.00	118.33	181.67
10512	26541	480.00	155.86	324.14
10513	26542	775.00	270.14	504.86
10514	26543	440.00	134.03	305.97
10515	26544	875.00	303.04	571.96
10516	26545	405.00	122.94	282.06
10517	26546	775.00	302.22	472.78
10518	26547	480.00	145.67	334.33
10519	26548	380.00	139.95	240.05
10520	26549	450.00	145.16	304.84
10521	26550	405.00	143.01	261.99
10522	26551	375.00	124.04	250.96
10523	26552	300.00	90.13	209.87
10524	26553	330.00	131.24	198.76
10525	26554	300.00	107.29	192.71
10526	26555	270.00	81.97	188.03
10527	26556	600.00	196.26	403.74
10528	26557	495.00	175.78	319.22
10529	26558	330.00	120.12	209.88
10530	26559	750.00	225.73	524.27
10531	26560	550.00	175.51	374.49
10532	26561	435.00	133.10	301.90
10533	26562	340.00	115.81	224.19
10534	26563	300.00	97.93	202.07
10535	26564	450.00	138.22	311.78
10536	26565	520.00	171.41	348.59
10537	26566	450.00	152.98	297.02
10538	26567	390.00	147.37	242.63
10539	26568	450.00	147.14	302.86
10540	26569	580.00	176.39	403.61
10541	26570	540.00	165.58	374.42
10542	26571	480.00	158.33	321.67
10543	26572	360.00	143.47	216.53
10544	26573	300.00	102.61	197.39
10545	26574	380.00	122.65	257.35
10546	26575	450.00	177.21	272.79
10547	26576	270.00	90.08	179.92
10548	26577	440.00	167.25	272.75
10549	26578	280.00	106.43	173.57
10550	26579	1000.00	347.01	652.99
10551	26580	435.00	152.58	282.42
10552	26581	420.00	148.56	271.44
10553	26582	420.00	155.93	264.07
10554	26583	420.00	131.04	288.96
10555	26584	950.00	351.71	598.29
10556	26585	525.00	179.87	345.13
10557	26586	420.00	139.38	280.62
10558	26587	750.00	293.81	456.19
10559	26588	800.00	243.62	556.38
10560	26589	650.00	219.32	430.68
10561	26590	260.00	85.36	174.64
10562	26591	495.00	194.15	300.85
10563	26592	500.00	199.63	300.37
10564	26593	340.00	115.53	224.47
10565	26594	500.00	161.05	338.95
10566	26595	560.00	212.52	347.48
10567	26596	650.00	198.36	451.64
10568	26597	480.00	150.54	329.46
10569	26598	300.00	98.26	201.74
10570	26599	345.00	136.83	208.17
10571	26600	345.00	121.21	223.79
10572	26601	360.00	117.21	242.79
10573	26602	900.00	280.22	619.78
10574	26603	440.00	164.63	275.37
10575	26604	285.00	104.88	180.12
10576	26605	500.00	196.21	303.79
10577	26606	625.00	224.13	400.87
10578	26607	390.00	124.74	265.26
10579	26608	320.00	119.52	200.48
10580	26609	420.00	167.82	252.18
10581	26610	625.00	230.29	394.71
10582	26611	375.00	142.05	232.95
10583	26612	300.00	105.99	194.01
10584	26613	400.00	143.84	256.16
10585	26614	525.00	174.28	350.72
10586	26615	550.00	188.66	361.34
10587	26616	420.00	132.98	287.02
10588	26617	700.00	224.99	475.01
10589	26618	510.00	156.44	353.56
10590	26619	525.00	196.46	328.54
10591	26620	600.00	213.81	386.19
10592	26621	360.00	126.41	233.59
10593	26622	465.00	140.13	324.87
10594	26623	375.00	133.14	241.86
10595	26624	390.00	124.40	265.60
10596	26625	525.00	189.38	335.62
10597	26626	285.00	86.46	198.54
10598	26627	725.00	267.09	457.91
10599	26628	360.00	128.57	231.43
10600	26629	360.00	123.84	236.16
10601	26630	775.00	277.12	497.88
10602	26631	600.00	227.16	372.84
10603	26632	1025.00	363.80	661.20
10604	26633	525.00	170.96	354.04
10605	26634	600.00	237.66	362.34
10606	26635	375.00	124.20	250.80
10607	26636	800.00	245.25	554.75
10608	26637	520.00	200.55	319.45
10609	26638	255.00	100.99	154.01
10610	26639	525.00	159.11	365.89
10611	26640	1025.00	326.72	698.28
10612	26641	440.00	165.27	274.73
10613	26642	525.00	202.92	322.08
10614	26643	315.00	105.61	209.39
10615	26644	825.00	287.39	537.61
10616	26645	300.00	105.88	194.12
10617	26646	300.00	94.12	205.88
10618	26647	435.00	153.23	281.77
10619	26648	500.00	164.99	335.01
10620	26649	825.00	271.16	553.84
10621	26650	900.00	311.64	588.36
10622	26651	480.00	166.29	313.71
10623	26652	580.00	189.37	390.63
10624	26653	340.00	118.52	221.48
10625	26654	600.00	226.05	373.95
10626	26655	950.00	350.65	599.35
10627	26656	320.00	98.62	221.38
10628	26657	495.00	184.26	310.74
10629	26658	465.00	151.85	313.15
10630	26659	950.00	294.84	655.16
10631	26660	300.00	99.27	200.73
10632	26661	575.00	216.00	359.00
10633	26662	400.00	135.69	264.31
10634	26663	800.00	301.95	498.05
10635	26664	345.00	126.40	218.60
10636	26665	390.00	127.13	262.87
10637	26666	360.00	143.53	216.47
10638	26667	925.00	319.66	605.34
10639	26668	390.00	148.01	241.99
10640	26669	285.00	104.51	180.49
10641	26670	330.00	105.25	224.75
10642	26671	700.00	220.15	479.85
10643	26672	270.00	105.97	164.03
10644	26673	390.00	140.72	249.28
10645	26674	460.00	173.04	286.96
10646	26675	260.00	82.58	177.42
10647	26676	1000.00	398.46	601.54
10648	26677	400.00	125.26	274.74
10649	26678	495.00	158.62	336.38
10650	26679	345.00	123.63	221.37
10651	26680	575.00	178.50	396.50
10652	26681	440.00	133.40	306.60
10653	26682	525.00	208.14	316.86
10654	26683	850.00	329.53	520.47
10655	26684	360.00	128.95	231.05
10656	26685	510.00	183.44	326.56
10657	26686	550.00	193.33	356.67
10658	26687	285.00	94.62	190.38
10659	26688	625.00	234.68	390.32
10660	26689	465.00	144.31	320.69
10661	26690	465.00	150.30	314.70
10662	26691	725.00	223.67	501.33
10663	26692	300.00	104.13	195.87
10664	26693	360.00	118.41	241.59
10665	26694	315.00	116.80	198.20
10666	26695	1000.00	378.86	621.14
10667	26696	825.00	308.45	516.55
10668	26697	300.00	110.14	189.86
10669	26698	300.00	101.68	198.32
10670	26699	375.00	135.91	239.09
10671	26700	495.00	178.36	316.64
10672	26701	600.00	181.71	418.29
10673	26702	500.00	198.63	301.37
10674	26703	525.00	163.84	361.16
10675	26704	330.00	123.59	206.41
10676	26705	525.00	166.57	358.43
10677	26706	360.00	113.90	246.10
10678	26707	925.00	313.65	611.35
10679	26708	650.00	243.62	406.38
10680	26709	525.00	203.08	321.92
10681	26710	600.00	219.60	380.40
10682	26711	525.00	204.47	320.53
10683	26712	800.00	297.94	502.06
10684	26713	525.00	174.94	350.06
10685	26714	480.00	169.54	310.46
10686	26715	465.00	144.73	320.27
10687	26716	975.00	377.93	597.07
10688	26717	775.00	263.44	511.56
10689	26718	510.00	169.15	340.85
10690	26719	580.00	179.52	400.48
10691	26720	525.00	164.35	360.65
10692	26721	900.00	338.62	561.38
10693	26722	495.00	181.89	313.11
10694	26723	315.00	113.06	201.94
10695	26724	495.00	167.68	327.32
10696	26725	400.00	136.21	263.79
10697	26726	360.00	122.72	237.28
10698	26727	340.00	105.20	234.80
10699	26728	525.00	209.38	315.62
10700	26729	270.00	99.82	170.18
10701	26730	330.00	111.77	218.23
10702	26731	380.00	128.61	251.39
10703	26732	375.00	127.23	247.77
10704	26733	360.00	133.51	226.49
10705	26734	300.00	93.57	206.43
10706	26735	465.00	177.12	287.88
10707	26736	850.00	264.77	585.23
10708	26737	420.00	166.34	253.66
10709	26738	525.00	178.05	346.95
10710	26739	465.00	172.61	292.39
10711	26740	390.00	145.53	244.47
10712	26741	560.00	196.73	363.27
10713	26742	525.00	203.90	321.10
10714	26743	330.00	113.42	216.58
10715	26744	300.00	103.12	196.88
10716	26745	260.00	85.86	174.14
10717	26746	900.00	281.43	618.57
10718	26747	285.00	112.47	172.53
10719	26748	420.00	153.37	266.63
10720	26749	925.00	284.49	640.51
10721	26750	460.00	180.33	279.67
10722	26751	495.00	174.21	320.79
10723	26752	900.00	351.12	548.88
10724	26753	285.00	104.67	180.33
10725	26754	435.00	135.75	299.25
10726	26755	320.00	109.88	210.12
10727	26756	510.00	179.39	330.61
10728	26757	850.00	306.96	543.04
10729	26758	345.00	137.65	207.35
10730	26759	360.00	122.79	237.21
10731	26760	405.00	146.47	258.53
10732	26761	315.00	124.21	190.79
10733	26762	975.00	339.86	635.14
10734	26763	850.00	337.16	512.84
10735	26764	580.00	187.16	392.84
10736	26765	725.00	245.34	479.66
10737	26766	800.00	296.43	503.57
10738	26767	240.00	75.09	164.91
10739	26768	800.00	306.91	493.09
10740	26769	560.00	184.00	376.00
10741	26770	380.00	132.32	247.68
10742	26771	675.00	223.70	451.30
10743	26772	450.00	166.81	283.19
10744	26773	320.00	99.37	220.63
10745	26774	240.00	73.57	166.43
10746	26775	320.00	113.52	206.48
10747	26776	700.00	237.48	462.52
10748	26777	600.00	187.68	412.32
10749	26778	625.00	200.59	424.41
10750	26779	875.00	306.89	568.11
10751	26780	520.00	191.10	328.90
10752	26781	775.00	301.58	473.42
10753	26782	750.00	277.93	472.07
10754	26783	390.00	155.68	234.32
10755	26784	270.00	95.34	174.66
10756	26785	580.00	199.85	380.15
10757	26786	875.00	282.18	592.82
10758	26787	525.00	171.19	353.81
10759	26788	450.00	176.98	273.02
10760	26789	280.00	109.74	170.26
10761	26790	360.00	131.05	228.95
10762	26791	525.00	208.94	316.06
10763	26792	420.00	138.59	281.41
10764	26793	440.00	143.47	296.53
10765	26794	775.00	280.28	494.72
10766	26795	510.00	186.15	323.85
10767	26796	360.00	130.19	229.81
10768	26797	440.00	132.63	307.37
10769	26798	525.00	205.71	319.29
10770	26799	345.00	107.99	237.01
10771	26800	360.00	143.36	216.64
10772	26801	435.00	149.41	285.59
10773	26802	480.00	185.60	294.40
10774	26803	975.00	300.05	674.95
10775	26804	925.00	342.09	582.91
10776	26805	495.00	156.28	338.72
10777	26806	450.00	149.63	300.37
10778	26807	465.00	149.22	315.78
10779	26808	950.00	286.39	663.61
10780	26809	825.00	249.79	575.21
10781	26810	675.00	221.34	453.66
10782	26811	520.00	199.26	320.74
10783	26812	390.00	119.29	270.71
10784	26813	480.00	149.79	330.21
10785	26814	390.00	121.64	268.36
10786	26815	600.00	193.22	406.78
10787	26816	390.00	134.28	255.72
10788	26817	460.00	169.30	290.70
10789	26818	420.00	165.37	254.63
10790	26819	525.00	196.77	328.23
10791	26820	480.00	180.15	299.85
10792	26821	300.00	110.78	189.22
10793	26822	360.00	111.99	248.01
10794	26823	315.00	120.94	194.06
10795	26824	270.00	90.23	179.77
10796	26825	345.00	117.56	227.44
10797	26826	675.00	234.38	440.62
10798	26827	435.00	144.18	290.82
10799	26828	750.00	296.43	453.57
10800	26829	525.00	163.00	362.00
10801	26830	435.00	169.20	265.80
10802	26831	625.00	207.15	417.85
10803	26832	525.00	188.20	336.80
10804	26833	450.00	175.04	274.96
10805	26834	340.00	122.16	217.84
10806	26835	480.00	191.20	288.80
10807	26836	315.00	98.09	216.91
10808	26837	575.00	188.45	386.55
10809	26838	510.00	173.37	336.63
10810	26839	520.00	188.80	331.20
10811	26840	500.00	162.29	337.71
10812	26841	360.00	124.05	235.95
10813	26842	360.00	112.28	247.72
10814	26843	500.00	162.57	337.43
10815	26844	345.00	111.21	233.79
10816	26845	285.00	113.51	171.49
10817	26846	950.00	343.04	606.96
10818	26847	480.00	173.76	306.24
10819	26848	270.00	94.07	175.93
10820	26849	510.00	194.31	315.69
10821	26850	1000.00	340.51	659.49
10822	26851	450.00	157.71	292.29
10823	26852	315.00	111.54	203.46
10824	26853	625.00	226.47	398.53
10825	26854	480.00	162.79	317.21
10826	26855	800.00	285.32	514.68
10827	26856	420.00	150.45	269.55
10828	26857	550.00	203.58	346.42
10829	26858	340.00	107.92	232.08
10830	26859	320.00	106.53	213.47
10831	26860	390.00	137.39	252.61
10832	26861	540.00	179.05	360.95
10833	26862	280.00	96.38	183.62
10834	26863	420.00	133.42	286.58
10835	26864	400.00	142.20	257.80
10836	26865	450.00	150.88	299.12
10837	26866	450.00	164.41	285.59
10838	26867	360.00	108.11	251.89
10839	26868	390.00	145.56	244.44
10840	26869	675.00	229.34	445.66
10841	26870	850.00	336.81	513.19
10842	26871	260.00	103.75	156.25
10843	26872	400.00	132.64	267.36
10844	26873	450.00	177.81	272.19
10845	26874	495.00	168.46	326.54
10846	26875	435.00	137.57	297.43
10847	26876	525.00	176.40	348.60
10848	26877	1025.00	357.87	667.13
10849	26878	300.00	94.75	205.25
10850	26879	525.00	175.14	349.86
10851	26880	510.00	172.09	337.91
10852	26881	330.00	123.63	206.37
10853	26882	435.00	145.09	289.91
10854	26883	550.00	198.39	351.61
10855	26884	550.00	181.83	368.17
10856	26885	380.00	121.39	258.61
10857	26886	460.00	142.79	317.21
10858	26887	300.00	111.33	188.67
10859	26888	600.00	197.18	402.82
10860	26889	300.00	119.34	180.66
10861	26890	450.00	151.91	298.09
10862	26891	345.00	123.08	221.92
10863	26892	495.00	184.01	310.99
10864	26893	850.00	300.06	549.94
10865	26894	600.00	233.63	366.37
10866	26895	420.00	150.67	269.33
10867	26896	315.00	104.30	210.70
10868	26897	525.00	176.82	348.18
10869	26898	300.00	95.98	204.02
10870	26899	550.00	165.49	384.51
10871	26900	480.00	180.77	299.23
10872	26901	315.00	95.42	219.58
10873	26902	1000.00	327.04	672.96
10874	26903	360.00	121.20	238.80
10875	26904	580.00	209.98	370.02
10876	26905	435.00	160.97	274.03
10877	26906	775.00	261.53	513.47
10878	26907	480.00	167.87	312.13
10879	26908	285.00	98.95	186.05
10880	26909	400.00	120.21	279.79
10881	26910	440.00	173.34	266.66
10882	26911	600.00	206.32	393.68
10883	26912	360.00	135.74	224.26
10884	26913	510.00	195.54	314.46
10885	26914	240.00	77.66	162.34
10886	26915	1025.00	316.44	708.56
10887	26916	575.00	204.09	370.91
10888	26917	510.00	201.52	308.48
10889	26918	465.00	166.68	298.32
10890	26919	420.00	142.65	277.35
10891	26920	380.00	118.81	261.19
10892	26921	500.00	165.75	334.25
10893	26922	330.00	124.42	205.58
10894	26923	420.00	141.16	278.84
10895	26924	725.00	246.43	478.57
10896	26925	440.00	157.19	282.81
10897	26926	380.00	126.78	253.22
10898	26927	825.00	292.24	532.76
10899	26928	260.00	102.87	157.13
10900	26929	285.00	99.07	185.93
10901	26930	270.00	105.00	165.00
10902	26931	900.00	346.79	553.21
10903	26932	435.00	144.16	290.84
10904	26933	440.00	135.49	304.51
10905	26934	750.00	297.15	452.85
10906	26935	260.00	91.81	168.19
10907	26936	525.00	182.67	342.33
10908	26937	600.00	230.57	369.43
10909	26938	525.00	202.55	322.45
10910	26939	380.00	143.53	236.47
10911	26940	375.00	148.20	226.80
10912	26941	300.00	115.85	184.15
10913	26942	520.00	171.08	348.92
10914	26943	600.00	191.99	408.01
10915	26944	300.00	115.35	184.65
10916	26945	875.00	267.59	607.41
10917	26946	440.00	162.61	277.39
10918	26947	465.00	177.77	287.23
10919	26948	875.00	294.12	580.88
10920	26949	345.00	107.33	237.67
10921	26950	375.00	115.79	259.21
10922	26951	405.00	157.56	247.44
10923	26952	320.00	104.32	215.68
10924	26953	380.00	129.27	250.73
10925	26954	435.00	169.83	265.17
10926	26955	405.00	160.43	244.57
10927	26956	520.00	199.72	320.28
10928	26957	725.00	243.15	481.85
10929	26958	1000.00	398.37	601.63
10930	26959	800.00	292.26	507.74
10931	26960	850.00	305.73	544.27
10932	26961	435.00	155.44	279.56
10933	26962	450.00	158.29	291.71
10934	26963	375.00	136.46	238.54
10935	26964	465.00	172.02	292.98
10936	26965	900.00	286.54	613.46
10937	26966	400.00	133.47	266.53
10938	26967	875.00	305.60	569.40
10939	26968	360.00	115.77	244.23
10940	26969	975.00	306.79	668.21
10941	26970	450.00	167.94	282.06
10942	26971	300.00	117.65	182.35
10943	26972	525.00	166.26	358.74
10944	26973	525.00	201.87	323.13
10945	26974	875.00	284.38	590.62
10946	26975	345.00	111.50	233.50
10947	26976	540.00	206.12	333.88
10948	26977	270.00	96.99	173.01
10949	26978	345.00	117.85	227.15
10950	26979	315.00	101.56	213.44
10951	26980	750.00	241.13	508.87
10952	26981	525.00	208.29	316.71
10953	26982	315.00	111.14	203.86
10954	26983	400.00	144.49	255.51
10955	26984	420.00	148.48	271.52
10956	26985	320.00	122.69	197.31
10957	26986	440.00	155.08	284.92
10958	26987	495.00	195.08	299.92
10959	26988	300.00	94.35	205.65
10960	26989	825.00	320.64	504.36
10961	26990	405.00	146.01	258.99
10962	26991	320.00	113.40	206.60
10963	26992	495.00	151.59	343.41
10964	26993	375.00	112.99	262.01
10965	26994	255.00	93.85	161.15
10966	26995	270.00	93.95	176.05
10967	26996	480.00	155.01	324.99
10968	26997	270.00	100.38	169.62
10969	26998	580.00	195.14	384.86
10970	26999	260.00	100.28	159.72
10971	27000	525.00	204.21	320.79
10972	27001	625.00	229.55	395.45
10973	27002	1000.00	338.94	661.06
10974	27003	465.00	157.98	307.02
10975	27004	330.00	128.55	201.45
10976	27005	525.00	179.65	345.35
10977	27006	750.00	255.36	494.64
10978	27007	510.00	189.94	320.06
10979	27008	400.00	148.08	251.92
10980	27009	825.00	324.96	500.04
10981	27010	460.00	158.10	301.90
10982	27011	390.00	147.13	242.87
10983	27012	400.00	149.37	250.63
10984	27013	480.00	171.66	308.34
10985	27014	525.00	161.28	363.72
10986	27015	825.00	271.78	553.22
10987	27016	260.00	78.59	181.41
10988	27017	405.00	141.91	263.09
10989	27018	510.00	191.07	318.93
10990	27019	300.00	92.30	207.70
10991	27020	495.00	174.92	320.08
10992	27021	460.00	156.40	303.60
10993	27022	725.00	248.28	476.72
10994	27023	345.00	109.07	235.93
10995	27024	725.00	285.02	439.98
10996	27025	925.00	366.85	558.15
10997	27026	800.00	256.83	543.17
10998	27027	440.00	164.21	275.79
10999	27028	285.00	88.73	196.27
11000	27029	300.00	114.31	185.69
11001	27030	465.00	145.03	319.97
11002	27031	360.00	111.09	248.91
11003	27032	270.00	85.65	184.35
11004	27033	320.00	105.86	214.14
11005	27034	300.00	106.72	193.28
11006	27035	420.00	160.78	259.22
11007	27036	600.00	191.14	408.86
11008	27037	875.00	263.48	611.52
11009	27038	315.00	101.16	213.84
11010	27039	330.00	100.15	229.85
11011	27040	465.00	143.15	321.85
11012	27041	575.00	193.78	381.22
11013	27042	850.00	273.28	576.72
11014	27043	495.00	162.82	332.18
11015	27044	315.00	123.71	191.29
11016	27045	510.00	178.83	331.17
11017	27046	480.00	183.95	296.05
11018	27047	360.00	119.72	240.28
11019	27048	315.00	108.27	206.73
11020	27049	405.00	150.46	254.54
11021	27050	390.00	147.60	242.40
11022	27051	925.00	279.67	645.33
11023	27052	675.00	264.92	410.08
11024	27053	1000.00	338.96	661.04
11025	27054	450.00	171.18	278.82
11026	27055	390.00	138.21	251.79
11027	27056	510.00	185.19	324.81
11028	27057	405.00	133.57	271.43
11029	27058	345.00	111.69	233.31
11030	27059	270.00	84.96	185.04
11031	27060	525.00	195.26	329.74
11032	27061	495.00	189.10	305.90
11033	27062	550.00	186.68	363.32
11034	27063	270.00	106.90	163.10
11035	27064	450.00	142.53	307.47
11036	27065	340.00	115.02	224.98
11037	27066	550.00	184.79	365.21
11038	27067	550.00	194.23	355.77
11039	27068	375.00	115.02	259.98
11040	27069	600.00	180.70	419.30
11041	27070	700.00	267.21	432.79
11042	27071	330.00	115.70	214.30
11043	27072	900.00	328.31	571.69
11044	27073	525.00	195.66	329.34
11045	27074	320.00	126.48	193.52
11046	27075	525.00	194.38	330.62
11047	27076	825.00	272.60	552.40
11048	27077	420.00	161.15	258.85
11049	27078	510.00	172.80	337.20
11050	27079	450.00	172.21	277.79
11051	27080	315.00	99.47	215.53
11052	27081	300.00	103.54	196.46
11053	27082	460.00	181.60	278.40
11054	27083	300.00	108.30	191.70
11055	27084	510.00	172.93	337.07
11056	27085	925.00	280.60	644.40
11057	27086	750.00	284.62	465.38
11058	27087	435.00	156.98	278.02
11059	27088	320.00	108.86	211.14
11060	27089	300.00	91.52	208.48
11061	27090	495.00	161.60	333.40
11062	27091	500.00	198.12	301.88
11063	27092	725.00	242.16	482.84
11064	27093	495.00	169.84	325.16
11065	27094	320.00	116.10	203.90
11066	27095	340.00	107.08	232.92
11067	27096	375.00	140.26	234.74
11068	27097	525.00	168.22	356.78
11069	27098	525.00	171.05	353.95
11070	27099	875.00	331.61	543.39
11071	27100	270.00	102.50	167.50
11072	27101	480.00	149.20	330.80
11073	27102	480.00	151.77	328.23
11074	27103	345.00	118.89	226.11
11075	27104	405.00	149.29	255.71
11076	27105	850.00	298.31	551.69
11077	27106	315.00	124.62	190.38
11078	27107	420.00	138.99	281.01
11079	27108	360.00	135.61	224.39
11080	27109	950.00	360.20	589.80
11081	27110	550.00	203.03	346.97
11082	27111	300.00	108.81	191.19
11083	27112	500.00	155.23	344.77
11084	27113	375.00	124.60	250.40
11085	27114	270.00	90.31	179.69
11086	27115	550.00	206.16	343.84
11087	27116	360.00	138.84	221.16
11088	27117	850.00	334.65	515.35
11089	27118	495.00	190.94	304.06
11090	27119	575.00	214.70	360.30
11091	27120	550.00	181.49	368.51
11092	27121	300.00	101.76	198.24
11093	27122	360.00	124.89	235.11
11094	27123	1000.00	388.10	611.90
11095	27124	825.00	320.54	504.46
11096	27125	420.00	161.90	258.10
11097	27126	480.00	176.25	303.75
11098	27127	675.00	267.84	407.16
11099	27128	1000.00	357.84	642.16
11100	27129	975.00	381.37	593.63
11101	27130	405.00	160.78	244.22
11102	27131	1025.00	390.54	634.46
11103	27132	435.00	131.44	303.56
11104	27133	480.00	155.60	324.40
11105	27134	975.00	364.85	610.15
11106	27135	550.00	187.11	362.89
11107	27136	300.00	109.75	190.25
11108	27137	405.00	151.85	253.15
11109	27138	300.00	112.55	187.45
11110	27139	580.00	183.84	396.16
11111	27140	875.00	285.66	589.34
11112	27141	390.00	125.79	264.21
11113	27142	285.00	97.67	187.33
11114	27143	650.00	258.32	391.68
11115	27144	375.00	134.72	240.28
11116	27145	375.00	137.69	237.31
11117	27146	405.00	135.66	269.34
11118	27147	345.00	109.79	235.21
11119	27148	825.00	254.64	570.36
11120	27149	380.00	132.48	247.52
11121	27150	280.00	94.70	185.30
11122	27151	405.00	140.82	264.18
11123	27152	825.00	320.38	504.62
11124	27153	465.00	161.98	303.02
11125	27154	450.00	175.35	274.65
11126	27155	650.00	228.54	421.46
11127	27156	375.00	131.65	243.35
11128	27157	500.00	177.24	322.76
11129	27158	925.00	366.01	558.99
11130	27159	435.00	172.99	262.01
11131	27160	825.00	306.94	518.06
11132	27161	390.00	118.13	271.87
11133	27162	270.00	103.72	166.28
11134	27163	345.00	110.78	234.22
11135	27164	270.00	82.93	187.07
11136	27165	255.00	86.82	168.18
11137	27166	450.00	179.93	270.07
11138	27167	435.00	153.55	281.45
11139	27168	390.00	147.93	242.07
11140	27169	435.00	136.83	298.17
11141	27170	600.00	229.85	370.15
11142	27171	800.00	315.11	484.89
11143	27172	800.00	266.55	533.45
11144	27173	260.00	101.89	158.11
11145	27174	775.00	266.43	508.57
11146	27175	625.00	222.28	402.72
11147	27176	465.00	176.17	288.83
11148	27177	435.00	134.31	300.69
11149	27178	270.00	82.35	187.65
11150	27179	675.00	267.97	407.03
11151	27180	420.00	163.16	256.84
11152	27181	375.00	147.45	227.55
11153	27182	360.00	136.47	223.53
11154	27183	390.00	154.66	235.34
11155	27184	580.00	200.41	379.59
11156	27185	435.00	141.70	293.30
11157	27186	450.00	172.53	277.47
11158	27187	300.00	118.31	181.69
11159	27188	440.00	133.48	306.52
11160	27189	650.00	215.95	434.05
11161	27190	420.00	126.32	293.68
11162	27191	525.00	163.21	361.79
11163	27192	775.00	249.90	525.10
11164	27193	320.00	98.04	221.96
11165	27194	320.00	112.51	207.49
11166	27195	575.00	207.40	367.60
11167	27196	725.00	279.56	445.44
11168	27197	925.00	301.08	623.92
11169	27198	340.00	112.26	227.74
11170	27199	600.00	190.93	409.07
11171	27200	495.00	162.16	332.84
11172	27201	285.00	88.29	196.71
11173	27202	725.00	247.73	477.27
11174	27203	750.00	272.61	477.39
11175	27204	600.00	201.75	398.25
11176	27205	380.00	147.21	232.79
11177	27206	750.00	245.07	504.93
11178	27207	360.00	143.13	216.87
11179	27208	750.00	268.24	481.76
11180	27209	500.00	180.33	319.67
11181	27210	285.00	95.21	189.79
11182	27211	600.00	205.74	394.26
11183	27212	420.00	138.59	281.41
11184	27213	975.00	312.24	662.76
11185	27214	580.00	210.96	369.04
11186	27215	775.00	235.49	539.51
11187	27216	875.00	285.26	589.74
11188	27217	1000.00	391.57	608.43
11189	27218	495.00	182.11	312.89
11190	27219	340.00	125.44	214.56
11191	27220	480.00	171.80	308.20
11192	27221	460.00	139.96	320.04
11193	27222	330.00	102.05	227.95
11194	27223	510.00	177.23	332.77
11195	27224	400.00	126.80	273.20
11196	27225	450.00	153.72	296.28
11197	27226	375.00	126.00	249.00
11198	27227	360.00	133.66	226.34
11199	27228	510.00	171.31	338.69
11200	27229	450.00	178.36	271.64
11201	27230	1025.00	347.44	677.56
11202	27231	320.00	106.25	213.75
11203	27232	480.00	165.40	314.60
11204	27233	390.00	118.31	271.69
11205	27234	260.00	82.47	177.53
11206	27235	580.00	209.61	370.39
11207	27236	500.00	166.95	333.05
11208	27237	975.00	337.59	637.41
11209	27238	440.00	160.15	279.85
11210	27239	465.00	174.48	290.52
11211	27240	800.00	275.58	524.42
11212	27241	240.00	77.83	162.17
11213	27242	300.00	117.04	182.96
11214	27243	725.00	222.59	502.41
11215	27244	550.00	174.45	375.55
11216	27245	725.00	252.82	472.18
11217	27246	850.00	279.27	570.73
11218	27247	345.00	105.76	239.24
11219	27248	440.00	170.25	269.75
11220	27249	975.00	303.93	671.07
11221	27250	435.00	164.53	270.47
11222	27251	650.00	195.21	454.79
11223	27252	405.00	142.44	262.56
11224	27253	825.00	290.26	534.74
11225	27254	450.00	154.05	295.95
11226	27255	1025.00	390.80	634.20
11227	27256	520.00	203.10	316.90
11228	27257	390.00	122.14	267.86
11229	27258	375.00	144.00	231.00
11230	27259	725.00	268.20	456.80
11231	27260	700.00	260.13	439.87
11232	27261	950.00	299.81	650.19
11233	27262	575.00	193.10	381.90
11234	27263	420.00	146.10	273.90
11235	27264	380.00	151.11	228.89
11236	27265	975.00	325.95	649.05
11237	27266	510.00	200.04	309.96
11238	27267	480.00	167.78	312.22
11239	27268	390.00	152.29	237.71
11240	27269	465.00	146.00	319.00
11241	27270	525.00	168.24	356.76
11242	27271	675.00	222.00	453.00
11243	27272	330.00	105.22	224.78
11244	27273	750.00	281.98	468.02
11245	27274	725.00	248.65	476.35
11246	27275	495.00	177.41	317.59
11247	27276	360.00	134.78	225.22
11248	27277	300.00	94.93	205.07
11249	27278	750.00	280.40	469.60
11250	27279	450.00	164.98	285.02
11251	27280	450.00	137.77	312.23
11252	27281	725.00	282.69	442.31
11253	27282	300.00	106.22	193.78
11254	27283	345.00	131.49	213.51
11255	27284	975.00	367.55	607.45
11256	27285	400.00	129.82	270.18
11257	27286	825.00	319.08	505.92
11258	27287	510.00	168.70	341.30
11259	27288	650.00	201.76	448.24
11260	27289	300.00	98.04	201.96
11261	27290	460.00	172.43	287.57
11262	27291	330.00	126.80	203.20
11263	27292	340.00	103.34	236.66
11264	27293	285.00	110.78	174.22
11265	27294	300.00	93.07	206.93
11266	27295	270.00	89.17	180.83
11267	27296	800.00	318.80	481.20
11268	27297	900.00	298.65	601.35
11269	27298	460.00	158.24	301.76
11270	27299	340.00	114.63	225.37
11271	27300	375.00	129.37	245.63
11272	27301	925.00	349.19	575.81
11273	27302	675.00	258.22	416.78
11274	27303	380.00	138.10	241.90
11275	27304	925.00	358.53	566.47
11276	27305	450.00	158.66	291.34
11277	27306	975.00	387.89	587.11
11278	27307	480.00	170.92	309.08
11279	27308	450.00	158.67	291.33
11280	27309	380.00	125.57	254.43
11281	27310	240.00	91.80	148.20
11282	27311	440.00	153.61	286.39
11283	27312	460.00	162.46	297.54
11284	27313	500.00	194.40	305.60
11285	27314	525.00	174.32	350.68
11286	27315	300.00	94.96	205.04
11287	27316	330.00	123.91	206.09
11288	27317	700.00	229.26	470.74
11289	27318	450.00	135.69	314.31
11290	27319	500.00	198.70	301.30
11291	27320	775.00	259.31	515.69
11292	27321	270.00	106.97	163.03
11293	27322	420.00	150.64	269.36
11294	27323	345.00	133.23	211.77
11295	27324	875.00	277.23	597.77
11296	27325	280.00	89.31	190.69
11297	27326	340.00	128.57	211.43
11298	27327	495.00	169.87	325.13
11299	27328	360.00	111.99	248.01
11300	27329	420.00	141.30	278.70
11301	27330	925.00	322.12	602.88
11302	27331	390.00	144.28	245.72
11303	27332	280.00	101.61	178.39
11304	27333	465.00	152.29	312.71
11305	27334	850.00	282.27	567.73
11306	27335	800.00	257.63	542.37
11307	27336	460.00	171.69	288.31
11308	27337	420.00	153.03	266.97
11309	27338	510.00	175.23	334.77
11310	27339	300.00	114.84	185.16
11311	27340	360.00	140.32	219.68
11312	27341	390.00	118.60	271.40
11313	27342	345.00	117.26	227.74
11314	27343	300.00	103.26	196.74
11315	27344	405.00	143.31	261.69
11316	27345	270.00	101.78	168.22
11317	27346	520.00	182.03	337.97
11318	27347	405.00	159.90	245.10
11319	27348	340.00	131.50	208.50
11320	27349	600.00	235.67	364.33
11321	27350	900.00	343.65	556.35
11322	27351	575.00	204.71	370.29
11323	27352	300.00	108.42	191.58
11324	27353	575.00	217.88	357.12
11325	27354	360.00	128.81	231.19
11326	27355	1000.00	313.80	686.20
11327	27356	775.00	291.06	483.94
11328	27357	575.00	196.43	378.57
11329	27358	390.00	125.05	264.95
11330	27359	360.00	125.74	234.26
11331	27360	600.00	216.71	383.29
11332	27361	320.00	108.99	211.01
11333	27362	340.00	106.06	233.94
11334	27363	315.00	119.76	195.24
11335	27364	750.00	257.96	492.04
11336	27365	925.00	323.81	601.19
11337	27366	925.00	286.28	638.72
11338	27367	650.00	242.93	407.07
11339	27368	510.00	172.17	337.83
11340	27369	345.00	104.74	240.26
11341	27370	315.00	114.69	200.31
11342	27371	285.00	100.64	184.36
11343	27372	300.00	106.71	193.29
11344	27373	950.00	332.03	617.97
11345	27374	420.00	160.16	259.84
11346	27375	420.00	138.14	281.86
11347	27376	440.00	172.64	267.36
11348	27377	285.00	112.50	172.50
11349	27378	495.00	169.05	325.95
11350	27379	575.00	199.19	375.81
11351	27380	300.00	112.54	187.46
11352	27381	480.00	163.74	316.26
11353	27382	1000.00	315.64	684.36
11354	27383	420.00	167.18	252.82
11355	27384	975.00	295.83	679.17
11356	27385	300.00	101.55	198.45
11357	27386	435.00	165.49	269.51
11358	27387	925.00	284.73	640.27
11359	27388	480.00	153.52	326.48
11360	27389	360.00	124.33	235.67
11361	27390	465.00	154.38	310.62
11362	27391	375.00	149.44	225.56
11363	27392	480.00	152.59	327.41
11364	27393	750.00	280.67	469.33
11365	27394	360.00	131.53	228.47
11366	27395	600.00	199.08	400.92
11367	27396	405.00	146.83	258.17
11368	27397	725.00	270.90	454.10
11369	27398	775.00	300.99	474.01
11370	27399	510.00	183.45	326.55
11371	27400	465.00	180.86	284.14
11372	27401	405.00	139.20	265.80
11373	27402	650.00	216.80	433.20
11374	27403	500.00	196.70	303.30
11375	27404	285.00	108.86	176.14
11376	27405	420.00	153.83	266.17
11377	27406	420.00	126.89	293.11
11378	27407	850.00	278.85	571.15
11379	27408	775.00	292.45	482.55
11380	27409	270.00	93.87	176.13
11381	27410	440.00	167.95	272.05
11382	27411	420.00	160.78	259.22
11383	27412	510.00	167.33	342.67
11384	27413	525.00	172.79	352.21
11385	27414	700.00	274.11	425.89
11386	27415	420.00	156.69	263.31
11387	27416	560.00	204.99	355.01
11388	27417	775.00	278.29	496.71
11389	27418	330.00	115.98	214.02
11390	27419	625.00	189.02	435.98
11391	27420	315.00	115.03	199.97
11392	27421	420.00	143.86	276.14
11393	27422	675.00	241.78	433.22
11394	27423	435.00	166.46	268.54
11395	27424	900.00	341.46	558.54
11396	27425	400.00	157.74	242.26
11397	27426	375.00	119.23	255.77
11398	27427	380.00	119.99	260.01
11399	27428	340.00	104.67	235.33
11400	27429	950.00	372.52	577.48
11401	27430	975.00	311.24	663.76
11402	27431	375.00	137.71	237.29
11403	27432	405.00	160.52	244.48
11404	27433	750.00	235.50	514.50
11405	27434	575.00	229.07	345.93
11406	27435	405.00	161.48	243.52
11407	27436	495.00	150.97	344.03
11408	27437	375.00	117.50	257.50
11409	27438	480.00	189.29	290.71
11410	27439	800.00	282.93	517.07
11411	27440	360.00	123.36	236.64
11412	27441	750.00	231.45	518.55
11413	27442	300.00	115.81	184.19
11414	27443	260.00	87.86	172.14
11415	27444	500.00	165.46	334.54
11416	27445	340.00	128.32	211.68
11417	27446	300.00	92.38	207.62
11418	27447	360.00	116.72	243.28
11419	27448	495.00	155.55	339.45
11420	27449	260.00	82.70	177.30
11421	27450	440.00	153.32	286.68
11422	27451	240.00	94.25	145.75
11423	27452	925.00	326.49	598.51
11424	27453	600.00	180.85	419.15
11425	27454	405.00	149.96	255.04
11426	27455	510.00	193.92	316.08
11427	27456	435.00	155.55	279.45
11428	27457	285.00	92.99	192.01
11429	27458	330.00	117.75	212.25
11430	27459	360.00	131.56	228.44
11431	27460	900.00	287.56	612.44
11432	27461	480.00	161.57	318.43
11433	27462	300.00	118.49	181.51
11434	27463	390.00	154.30	235.70
11435	27464	345.00	126.65	218.35
11436	27465	315.00	117.48	197.52
11437	27466	520.00	163.43	356.57
11438	27467	825.00	278.45	546.55
11439	27468	390.00	144.89	245.11
11440	27469	300.00	114.75	185.25
11441	27470	300.00	118.75	181.25
11442	27471	345.00	107.29	237.71
11443	27472	450.00	174.34	275.66
11444	27473	440.00	133.74	306.26
11445	27474	510.00	153.69	356.31
11446	27475	320.00	98.33	221.67
11447	27476	525.00	175.88	349.12
11448	27477	525.00	184.00	341.00
11449	27478	750.00	278.13	471.87
11450	27479	300.00	118.55	181.45
11451	27480	315.00	107.46	207.54
11452	27481	300.00	107.75	192.25
11453	27482	900.00	293.78	606.22
11454	27483	330.00	104.96	225.04
11455	27484	435.00	171.63	263.37
11456	27485	270.00	102.47	167.53
11457	27486	375.00	135.10	239.90
11458	27487	435.00	144.01	290.99
11459	27488	435.00	163.72	271.28
11460	27489	420.00	150.75	269.25
11461	27490	405.00	139.58	265.42
11462	27491	345.00	117.66	227.34
11463	27492	510.00	162.86	347.14
11464	27493	900.00	355.81	544.19
11465	27494	825.00	253.18	571.82
11466	27495	1025.00	407.72	617.28
11467	27496	460.00	172.46	287.54
11468	27497	405.00	148.14	256.86
11469	27498	270.00	102.16	167.84
11470	27499	420.00	151.72	268.28
11471	27500	270.00	106.73	163.27
11472	27501	510.00	157.79	352.21
11473	27502	340.00	109.00	231.00
11474	27503	405.00	137.75	267.25
11475	27504	390.00	140.41	249.59
11476	27505	380.00	132.09	247.91
11477	27506	420.00	141.13	278.87
11478	27507	560.00	171.32	388.68
11479	27508	450.00	174.96	275.04
11480	27509	480.00	180.85	299.15
11481	27510	560.00	221.75	338.25
11482	27511	675.00	203.14	471.86
11483	27512	650.00	244.39	405.61
11484	27513	550.00	214.83	335.17
11485	27514	450.00	145.84	304.16
11486	27515	1025.00	320.84	704.16
11487	27516	480.00	155.58	324.42
11488	27517	850.00	290.90	559.10
11489	27518	480.00	173.71	306.29
11490	27519	525.00	208.17	316.83
11491	27520	390.00	131.89	258.11
11492	27521	320.00	105.02	214.98
11493	27522	380.00	151.96	228.04
11494	27523	320.00	112.68	207.32
11495	27524	390.00	140.24	249.76
11496	27525	510.00	160.95	349.05
11497	27526	285.00	104.23	180.77
11498	27527	285.00	110.44	174.56
11499	27528	270.00	93.55	176.45
11500	27529	390.00	134.08	255.92
11501	27530	375.00	129.79	245.21
11502	27531	360.00	108.58	251.42
11503	27532	380.00	135.33	244.67
11504	27533	520.00	199.15	320.85
11505	27534	360.00	130.01	229.99
11506	27535	420.00	141.75	278.25
11507	27536	420.00	143.79	276.21
11508	27537	975.00	389.02	585.98
11509	27538	285.00	102.76	182.24
11510	27539	330.00	102.67	227.33
11511	27540	800.00	313.69	486.31
11512	27541	480.00	163.57	316.43
11513	27542	285.00	100.42	184.58
11514	27543	440.00	136.42	303.58
11515	27544	500.00	192.12	307.88
11516	27545	520.00	165.82	354.18
11517	27546	500.00	167.65	332.35
11518	27547	625.00	202.53	422.47
11519	27548	550.00	213.05	336.95
11520	27549	875.00	305.72	569.28
11521	27550	450.00	176.85	273.15
11522	27551	450.00	140.91	309.09
11523	27552	440.00	146.31	293.69
11524	27553	510.00	154.56	355.44
11525	27554	510.00	198.50	311.50
11526	27555	850.00	295.47	554.53
11527	27556	500.00	185.36	314.64
11528	27557	400.00	145.25	254.75
11529	27558	575.00	207.91	367.09
11530	27559	480.00	181.80	298.20
11531	27560	575.00	198.24	376.76
11532	27561	520.00	185.54	334.46
11533	27562	330.00	114.71	215.29
11534	27563	525.00	169.60	355.40
11535	27564	340.00	105.87	234.13
11536	27565	560.00	172.33	387.67
11537	27566	675.00	203.16	471.84
11538	27567	300.00	109.33	190.67
11539	27568	465.00	173.59	291.41
11540	27569	300.00	97.87	202.13
11541	27570	675.00	234.47	440.53
11542	27571	360.00	139.39	220.61
11543	27572	360.00	142.95	217.05
11544	27573	825.00	280.56	544.44
11545	27574	360.00	118.44	241.56
11546	27575	345.00	122.08	222.92
11547	27576	260.00	101.22	158.78
11548	27577	975.00	319.73	655.27
11549	27578	510.00	196.37	313.63
11550	27579	320.00	104.67	215.33
11551	27580	360.00	118.45	241.55
11552	27581	420.00	160.32	259.68
11553	27582	460.00	151.66	308.34
11554	27583	560.00	207.86	352.14
11555	27584	375.00	123.23	251.77
11556	27585	345.00	123.69	221.31
11557	27586	950.00	357.00	593.00
11558	27587	360.00	116.04	243.96
11559	27588	400.00	150.09	249.91
11560	27589	465.00	147.49	317.51
11561	27590	825.00	300.52	524.48
11562	27591	435.00	148.68	286.32
11563	27592	725.00	243.70	481.30
11564	27593	725.00	265.66	459.34
11565	27594	480.00	157.95	322.05
11566	27595	460.00	139.31	320.69
11567	27596	405.00	143.00	262.00
11568	27597	540.00	171.14	368.86
11569	27598	550.00	204.33	345.67
11570	27599	330.00	102.02	227.98
11571	27600	360.00	142.47	217.53
11572	27601	315.00	123.72	191.28
11573	27602	495.00	171.79	323.21
11574	27603	435.00	146.07	288.93
11575	27604	435.00	172.85	262.15
11576	27605	510.00	153.48	356.52
11577	27606	360.00	125.68	234.32
11578	27607	550.00	193.81	356.19
11579	27608	525.00	205.10	319.90
11580	27609	400.00	143.02	256.98
11581	27610	465.00	148.55	316.45
11582	27611	825.00	327.23	497.77
11583	27612	480.00	163.78	316.22
11584	27613	270.00	90.01	179.99
11585	27614	750.00	296.36	453.64
11586	27615	1000.00	399.65	600.35
11587	27616	420.00	161.59	258.41
11588	27617	420.00	127.69	292.31
11589	27618	285.00	93.81	191.19
11590	27619	480.00	151.67	328.33
11591	27620	625.00	211.56	413.44
11592	27621	460.00	143.83	316.17
11593	27622	345.00	105.89	239.11
11594	27623	390.00	151.43	238.57
11595	27624	625.00	211.27	413.73
11596	27625	450.00	147.77	302.23
11597	27626	510.00	191.25	318.75
11598	27627	825.00	300.05	524.95
11599	27628	285.00	112.39	172.61
11600	27629	550.00	201.30	348.70
11601	27630	495.00	165.15	329.85
11602	27631	850.00	291.43	558.57
11603	27632	345.00	113.28	231.72
11604	27633	500.00	190.50	309.50
11605	27634	525.00	172.67	352.33
11606	27635	405.00	154.12	250.88
11607	27636	495.00	197.67	297.33
11608	27637	440.00	165.05	274.95
11609	27638	315.00	118.64	196.36
11610	27639	650.00	236.24	413.76
11611	27640	510.00	168.75	341.25
11612	27641	625.00	231.42	393.58
11613	27642	380.00	117.01	262.99
11614	27643	440.00	160.18	279.82
11615	27644	875.00	281.77	593.23
11616	27645	600.00	228.84	371.16
11617	27646	315.00	112.78	202.22
11618	27647	315.00	108.42	206.58
11619	27648	500.00	193.84	306.16
11620	27649	625.00	249.10	375.90
11621	27650	380.00	144.06	235.94
11622	27651	510.00	184.69	325.31
11623	27652	465.00	149.14	315.86
11624	27653	340.00	103.27	236.73
11625	27654	300.00	93.22	206.78
11626	27655	420.00	147.13	272.87
11627	27656	875.00	293.26	581.74
11628	27657	700.00	223.26	476.74
11629	27658	800.00	305.91	494.09
11630	27659	420.00	139.65	280.35
11631	27660	950.00	290.14	659.86
11632	27661	300.00	95.17	204.83
11633	27662	405.00	130.71	274.29
11634	27663	850.00	258.20	591.80
11635	27664	270.00	83.27	186.73
11636	27665	775.00	258.33	516.67
11637	27666	510.00	171.36	338.64
11638	27667	405.00	138.02	266.98
11639	27668	360.00	142.99	217.01
11640	27669	300.00	98.55	201.45
11641	27670	360.00	110.10	249.90
11642	27671	625.00	240.60	384.40
11643	27672	435.00	172.46	262.54
11644	27673	300.00	117.74	182.26
11645	27674	420.00	164.22	255.78
11646	27675	525.00	201.60	323.40
11647	27676	1025.00	384.06	640.94
11648	27677	440.00	164.50	275.50
11649	27678	550.00	176.05	373.95
11650	27679	390.00	148.44	241.56
11651	27680	280.00	105.74	174.26
11652	27681	800.00	297.65	502.35
11653	27682	480.00	152.71	327.29
11654	27683	420.00	148.77	271.23
11655	27684	420.00	135.68	284.32
11656	27685	495.00	186.50	308.50
11657	27686	320.00	115.01	204.99
11658	27687	450.00	159.76	290.24
11659	27688	550.00	171.94	378.06
11660	27689	510.00	189.20	320.80
11661	27690	435.00	165.51	269.49
11662	27691	450.00	137.24	312.76
11663	27692	400.00	130.93	269.07
11664	27693	330.00	111.99	218.01
11665	27694	270.00	106.51	163.49
11666	27695	375.00	133.17	241.83
11667	27696	345.00	107.85	237.15
11668	27697	465.00	150.09	314.91
11669	27698	330.00	125.55	204.45
11670	27699	300.00	94.76	205.24
11671	27700	575.00	177.07	397.93
11672	27701	340.00	121.31	218.69
11673	27702	360.00	129.38	230.62
11674	27703	900.00	356.33	543.67
11675	27704	375.00	131.51	243.49
11676	27705	480.00	155.40	324.60
11677	27706	375.00	121.68	253.32
11678	27707	510.00	154.30	355.70
11679	27708	1025.00	382.78	642.22
11680	27709	600.00	226.24	373.76
11681	27710	285.00	110.18	174.82
11682	27711	525.00	166.98	358.02
11683	27712	405.00	133.29	271.71
11684	27713	850.00	297.12	552.88
11685	27714	450.00	170.06	279.94
11686	27715	875.00	284.65	590.35
11687	27716	1000.00	342.62	657.38
11688	27717	440.00	144.50	295.50
11689	27718	480.00	184.68	295.32
11690	27719	700.00	219.64	480.36
11691	27720	500.00	181.64	318.36
11692	27721	825.00	266.90	558.10
11693	27722	405.00	149.43	255.57
11694	27723	300.00	99.70	200.30
11695	27724	480.00	160.37	319.63
11696	27725	900.00	335.79	564.21
11697	27726	320.00	107.16	212.84
11698	27727	260.00	88.24	171.76
11699	27728	375.00	118.13	256.87
11700	27729	520.00	174.83	345.17
11701	27730	405.00	159.07	245.93
11702	27731	300.00	90.18	209.82
11703	27732	450.00	146.17	303.83
11704	27733	500.00	155.06	344.94
11705	27734	380.00	123.79	256.21
11706	27735	975.00	352.04	622.96
11707	27736	315.00	97.79	217.21
11708	27737	850.00	305.83	544.17
11709	27738	675.00	210.19	464.81
11710	27739	540.00	200.32	339.68
11711	27740	480.00	164.57	315.43
11712	27741	465.00	151.15	313.85
11713	27742	650.00	222.90	427.10
11714	27743	465.00	152.16	312.84
11715	27744	375.00	146.40	228.60
11716	27745	330.00	114.62	215.38
11717	27746	495.00	155.05	339.95
11718	27747	360.00	131.04	228.96
11719	27748	580.00	231.74	348.26
11720	27749	300.00	105.94	194.06
11721	27750	800.00	259.03	540.97
11722	27751	320.00	97.80	222.20
11723	27752	600.00	194.86	405.14
11724	27753	435.00	164.98	270.02
11725	27754	405.00	145.72	259.28
11726	27755	510.00	172.81	337.19
11727	27756	390.00	127.54	262.46
11728	27757	625.00	213.92	411.08
11729	27758	270.00	97.15	172.85
11730	27759	480.00	171.92	308.08
11731	27760	700.00	272.23	427.77
11732	27761	405.00	150.30	254.70
11733	27762	495.00	186.44	308.56
11734	27763	450.00	163.42	286.58
11735	27764	270.00	96.66	173.34
11736	27765	465.00	160.08	304.92
11737	27766	510.00	188.93	321.07
11738	27767	375.00	137.79	237.21
11739	27768	420.00	159.59	260.41
11740	27769	850.00	270.87	579.13
11741	27770	340.00	119.82	220.18
11742	27771	330.00	102.10	227.90
11743	27772	465.00	177.52	287.48
11744	27773	435.00	134.40	300.60
11745	27774	800.00	294.63	505.37
11746	27775	315.00	100.64	214.36
11747	27776	495.00	194.80	300.20
11748	27777	320.00	126.44	193.56
11749	27778	280.00	96.39	183.61
11750	27779	345.00	120.24	224.76
11751	27780	575.00	190.39	384.61
11752	27781	925.00	298.01	626.99
11753	27782	460.00	144.97	315.03
11754	27783	650.00	196.72	453.28
11755	27784	575.00	220.71	354.29
11756	27785	420.00	149.78	270.22
11757	27786	380.00	121.75	258.25
11758	27787	405.00	141.40	263.60
11759	27788	270.00	99.37	170.63
11760	27789	775.00	281.52	493.48
11761	27790	450.00	160.73	289.27
11762	27791	925.00	340.22	584.78
11763	27792	405.00	129.27	275.73
11764	27793	450.00	146.29	303.71
11765	27794	360.00	134.86	225.14
11766	27795	850.00	265.00	585.00
11767	27796	440.00	142.12	297.88
11768	27797	380.00	151.30	228.70
11769	27798	480.00	153.14	326.86
11770	27799	435.00	173.98	261.02
11771	27800	285.00	111.78	173.22
11772	27801	510.00	164.83	345.17
11773	27802	800.00	266.83	533.17
11774	27803	750.00	292.06	457.94
11775	27804	465.00	149.36	315.64
11776	27805	360.00	132.42	227.58
11777	27806	525.00	164.43	360.57
11778	27807	725.00	232.89	492.11
11779	27808	800.00	284.70	515.30
11780	27809	380.00	140.88	239.12
11781	27810	380.00	143.40	236.60
11782	27811	600.00	199.32	400.68
11783	27812	315.00	99.26	215.74
11784	27813	875.00	278.38	596.62
11785	27814	465.00	170.89	294.11
11786	27815	405.00	151.73	253.27
11787	27816	675.00	246.51	428.49
11788	27817	1025.00	335.45	689.55
11789	27818	510.00	201.04	308.96
11790	27819	900.00	327.60	572.40
11791	27820	280.00	98.42	181.58
11792	27821	1000.00	373.67	626.33
11793	27822	560.00	203.22	356.78
11794	27823	875.00	282.88	592.12
11795	27824	700.00	241.08	458.92
11796	27825	950.00	351.64	598.36
11797	27826	480.00	148.46	331.54
11798	27827	775.00	237.97	537.03
11799	27828	360.00	138.36	221.64
11800	27829	875.00	350.00	525.00
11801	27830	460.00	143.09	316.91
11802	27831	750.00	228.86	521.14
11803	27832	480.00	190.23	289.77
11804	27833	280.00	102.71	177.29
11805	27834	525.00	185.96	339.04
11806	27835	280.00	97.34	182.66
11807	27836	420.00	167.30	252.70
11808	27837	750.00	276.08	473.92
11809	27838	480.00	146.46	333.54
11810	27839	435.00	148.61	286.39
11811	27840	550.00	168.40	381.60
11812	27841	420.00	163.52	256.48
11813	27842	600.00	220.91	379.09
11814	27843	315.00	113.66	201.34
11815	27844	510.00	203.85	306.15
11816	27845	280.00	91.55	188.45
11817	27846	900.00	312.15	587.85
11818	27847	675.00	235.39	439.61
11819	27848	575.00	219.98	355.02
11820	27849	525.00	192.82	332.18
11821	27850	480.00	169.65	310.35
11822	27851	320.00	121.27	198.73
11823	27852	360.00	141.27	218.73
11824	27853	225.00	74.82	150.18
11825	27854	420.00	142.44	277.56
11826	27855	315.00	111.75	203.25
11827	27856	435.00	160.50	274.50
11828	27857	925.00	281.89	643.11
11829	27858	700.00	222.19	477.81
11830	27859	500.00	199.46	300.54
11831	27860	450.00	156.32	293.68
11832	27861	480.00	177.67	302.33
11833	27862	510.00	180.60	329.40
11834	27863	285.00	105.86	179.14
11835	27864	450.00	169.09	280.91
11836	27865	360.00	110.56	249.44
11837	27866	875.00	346.58	528.42
11838	27867	480.00	164.33	315.67
11839	27868	270.00	91.16	178.84
11840	27869	260.00	99.90	160.10
11841	27870	540.00	201.12	338.88
11842	27871	750.00	233.66	516.34
11843	27872	345.00	118.12	226.88
11844	27873	510.00	193.37	316.63
11845	27874	510.00	193.06	316.94
11846	27875	580.00	211.07	368.93
11847	27876	225.00	84.40	140.60
11848	27877	550.00	172.87	377.13
11849	27878	510.00	192.21	317.79
11850	27879	320.00	103.62	216.38
11851	27880	675.00	269.91	405.09
11852	27881	1000.00	313.05	686.95
11853	27882	1000.00	357.65	642.35
11854	27883	480.00	162.17	317.83
11855	27884	225.00	79.75	145.25
11856	27885	460.00	180.49	279.51
11857	27886	450.00	159.27	290.73
11858	27887	340.00	119.51	220.49
11859	27888	320.00	125.36	194.64
11860	27889	480.00	160.38	319.62
11861	27890	270.00	92.23	177.77
11862	27891	1025.00	345.42	679.58
11863	27892	300.00	108.06	191.94
11864	27893	525.00	182.74	342.26
11865	27894	420.00	144.22	275.78
11866	27895	850.00	283.47	566.53
11867	27896	270.00	96.68	173.32
11868	27897	900.00	313.32	586.68
11869	27898	675.00	232.96	442.04
11870	27899	900.00	341.09	558.91
11871	27900	300.00	99.38	200.62
11872	27901	465.00	165.38	299.62
11873	27902	315.00	98.73	216.27
11874	27903	540.00	200.04	339.96
11875	27904	340.00	128.64	211.36
11876	27905	390.00	147.10	242.90
11877	27906	375.00	125.84	249.16
11878	27907	375.00	133.45	241.55
11879	27908	285.00	101.78	183.22
11880	27909	315.00	100.50	214.50
11881	27910	775.00	273.71	501.29
11882	27911	300.00	94.72	205.28
11883	27912	925.00	348.79	576.21
11884	27913	480.00	158.43	321.57
11885	27914	520.00	188.39	331.61
11886	27915	360.00	127.95	232.05
11887	27916	435.00	146.55	288.45
11888	27917	510.00	181.42	328.58
11889	27918	405.00	158.10	246.90
11890	27919	420.00	132.75	287.25
11891	27920	360.00	129.78	230.22
11892	27921	650.00	240.26	409.74
11893	27922	495.00	175.44	319.56
11894	27923	400.00	146.68	253.32
11895	27924	800.00	268.70	531.30
11896	27925	480.00	166.07	313.93
11897	27926	480.00	153.74	326.26
11898	27927	825.00	278.36	546.64
11899	27928	435.00	163.69	271.31
11900	27929	330.00	119.86	210.14
11901	27930	465.00	175.31	289.69
11902	27931	950.00	371.01	578.99
11903	27932	285.00	94.19	190.81
11904	27933	725.00	263.48	461.52
11905	27934	675.00	202.96	472.04
11906	27935	300.00	119.61	180.39
11907	27936	525.00	193.24	331.76
11908	27937	285.00	87.68	197.32
11909	27938	650.00	220.64	429.36
11910	27939	460.00	170.33	289.67
11911	27940	510.00	183.67	326.33
11912	27941	700.00	254.38	445.62
11913	27942	315.00	101.63	213.37
11914	27943	480.00	164.84	315.16
11915	27944	270.00	85.84	184.16
11916	27945	950.00	288.67	661.33
11917	27946	600.00	227.25	372.75
11918	27947	390.00	118.61	271.39
11919	27948	750.00	225.84	524.16
11920	27949	500.00	184.71	315.29
11921	27950	465.00	144.99	320.01
11922	27951	525.00	161.09	363.91
11923	27952	400.00	132.41	267.59
11924	27953	300.00	119.18	180.82
11925	27954	480.00	161.67	318.33
11926	27955	315.00	117.06	197.94
11927	27956	675.00	235.39	439.61
11928	27957	825.00	325.58	499.42
11929	27958	360.00	134.68	225.32
11930	27959	285.00	110.08	174.92
11931	27960	600.00	192.43	407.57
11932	27961	260.00	78.31	181.69
11933	27962	1025.00	308.13	716.87
11934	27963	300.00	94.63	205.37
11935	27964	380.00	149.79	230.21
11936	27965	625.00	204.47	420.53
11937	27966	270.00	93.49	176.51
11938	27967	480.00	182.57	297.43
11939	27968	600.00	235.63	364.37
11940	27969	345.00	124.01	220.99
11941	27970	300.00	117.53	182.47
11942	27971	560.00	212.79	347.21
11943	27972	525.00	181.84	343.16
11944	27973	495.00	159.23	335.77
11945	27974	300.00	109.43	190.57
11946	27975	330.00	124.25	205.75
11947	27976	520.00	188.55	331.45
11948	27977	950.00	353.05	596.95
11949	27978	510.00	178.17	331.83
11950	27979	450.00	161.92	288.08
11951	27980	285.00	106.25	178.75
11952	27981	480.00	186.21	293.79
11953	27982	525.00	157.86	367.14
11954	27983	300.00	119.43	180.57
11955	27984	480.00	184.32	295.68
11956	27985	405.00	151.73	253.27
11957	27986	400.00	120.64	279.36
11958	27987	975.00	371.24	603.76
11959	27988	510.00	170.13	339.87
11960	27989	420.00	160.21	259.79
11961	27990	340.00	120.14	219.86
11962	27991	435.00	153.20	281.80
11963	27992	440.00	150.78	289.22
11964	27993	420.00	158.24	261.76
11965	27994	300.00	104.95	195.05
11966	27995	270.00	103.36	166.64
11967	27996	480.00	149.65	330.35
11968	27997	495.00	187.69	307.31
11969	27998	330.00	119.92	210.08
11970	27999	400.00	129.13	270.87
11971	28000	575.00	174.17	400.83
11972	28001	975.00	386.53	588.47
11973	28002	285.00	95.39	189.61
11974	28003	525.00	169.00	356.00
11975	28004	420.00	152.12	267.88
11976	28005	950.00	340.36	609.64
11977	28006	950.00	340.95	609.05
11978	28007	495.00	171.78	323.22
11979	28008	450.00	160.50	289.50
11980	28009	525.00	163.86	361.14
11981	28010	435.00	163.47	271.53
11982	28011	525.00	191.05	333.95
11983	28012	300.00	98.82	201.18
11984	28013	360.00	137.83	222.17
11985	28014	480.00	149.96	330.04
11986	28015	435.00	153.68	281.32
11987	28016	300.00	93.61	206.39
11988	28017	500.00	198.72	301.28
11989	28018	500.00	153.77	346.23
11990	28019	285.00	113.08	171.92
11991	28020	580.00	202.99	377.01
11992	28021	725.00	261.48	463.52
11993	28022	390.00	144.54	245.46
11994	28023	435.00	136.85	298.15
11995	28024	420.00	166.62	253.38
11996	28025	700.00	245.14	454.86
11997	28026	900.00	273.68	626.32
11998	28027	345.00	112.49	232.51
11999	28028	460.00	143.89	316.11
12000	28029	285.00	111.24	173.76
12001	28030	285.00	92.51	192.49
12002	28031	925.00	333.63	591.37
12003	28032	480.00	152.91	327.09
12004	28033	725.00	232.78	492.22
12005	28034	360.00	118.89	241.11
12006	28035	225.00	82.16	142.84
12007	28036	825.00	283.72	541.28
12008	28037	480.00	163.19	316.81
12009	28038	360.00	136.03	223.97
12010	28039	1000.00	340.51	659.49
12011	28040	340.00	104.28	235.72
12012	28041	300.00	112.13	187.87
12013	28042	850.00	277.32	572.68
12014	28043	750.00	226.72	523.28
12015	28044	315.00	116.12	198.88
12016	28045	900.00	318.42	581.58
12017	28046	900.00	301.39	598.61
12018	28047	540.00	184.35	355.65
12019	28048	750.00	234.18	515.82
12020	28049	800.00	265.83	534.17
12021	28050	825.00	270.28	554.72
12022	28051	340.00	135.93	204.07
12023	28052	360.00	143.06	216.94
12024	28053	460.00	174.95	285.05
12025	28054	300.00	100.30	199.70
12026	28055	825.00	302.40	522.60
12027	28056	405.00	125.00	280.00
12028	28057	600.00	210.14	389.86
12029	28058	650.00	254.04	395.96
12030	28059	300.00	113.53	186.47
12031	28060	380.00	140.86	239.14
12032	28061	900.00	310.18	589.82
12033	28062	500.00	192.93	307.07
12034	28063	625.00	237.20	387.80
12035	28064	460.00	162.53	297.47
12036	28065	800.00	250.58	549.42
12037	28066	525.00	190.54	334.46
12038	28067	480.00	159.44	320.56
12039	28068	300.00	113.98	186.02
12040	28069	330.00	111.42	218.58
12041	28070	390.00	152.74	237.26
12042	28071	480.00	160.88	319.12
12043	28072	400.00	158.79	241.21
12044	28073	405.00	157.06	247.94
12045	28074	725.00	259.58	465.42
12046	28075	375.00	133.21	241.79
12047	28076	300.00	97.48	202.52
12048	28077	440.00	142.03	297.97
12049	28078	440.00	141.30	298.70
12050	28079	300.00	112.91	187.09
12051	28080	525.00	163.35	361.65
12052	28081	440.00	134.87	305.13
12053	28082	435.00	158.50	276.50
12054	28083	1025.00	373.05	651.95
12055	28084	875.00	334.45	540.55
12056	28085	625.00	241.20	383.80
12057	28086	850.00	302.58	547.42
12058	28087	550.00	200.33	349.67
12059	28088	435.00	164.10	270.90
12060	28089	525.00	170.80	354.20
12061	28090	420.00	141.57	278.43
12062	28091	550.00	196.06	353.94
12063	28092	285.00	90.96	194.04
12064	28093	520.00	199.42	320.58
12065	28094	435.00	170.78	264.22
12066	28095	525.00	167.52	357.48
12067	28096	510.00	165.48	344.52
12068	28097	270.00	96.94	173.06
12069	28098	510.00	201.73	308.27
12070	28099	360.00	138.77	221.23
12071	28100	340.00	121.92	218.08
12072	28101	330.00	125.36	204.64
12073	28102	480.00	172.30	307.70
12074	28103	460.00	170.77	289.23
12075	28104	420.00	165.97	254.03
12076	28105	1025.00	307.87	717.13
12077	28106	465.00	139.89	325.11
12078	28107	315.00	123.57	191.43
12079	28108	340.00	123.59	216.41
12080	28109	900.00	297.75	602.25
12081	28110	330.00	130.53	199.47
12082	28111	435.00	133.29	301.71
12083	28112	550.00	188.84	361.16
12084	28113	345.00	107.40	237.60
12085	28114	435.00	151.87	283.13
12086	28115	480.00	163.19	316.81
12087	28116	600.00	229.16	370.84
12088	28117	1025.00	324.76	700.24
12089	28118	315.00	103.01	211.99
12090	28119	520.00	178.50	341.50
12091	28120	420.00	131.02	288.98
12092	28121	700.00	240.41	459.59
12093	28122	440.00	164.15	275.85
12094	28123	360.00	130.35	229.65
12095	28124	345.00	134.37	210.63
12096	28125	300.00	116.46	183.54
12097	28126	320.00	113.06	206.94
12098	28127	480.00	187.86	292.14
12099	28128	270.00	102.41	167.59
12100	28129	255.00	99.36	155.64
12101	28130	435.00	133.54	301.46
12102	28131	525.00	167.48	357.52
12103	28132	360.00	133.11	226.89
12104	28133	800.00	290.58	509.42
12105	28134	750.00	231.05	518.95
12106	28135	270.00	96.48	173.52
12107	28136	520.00	200.55	319.45
12108	28137	480.00	170.94	309.06
12109	28138	340.00	102.57	237.43
12110	28139	340.00	118.04	221.96
12111	28140	390.00	149.48	240.52
12112	28141	440.00	159.57	280.43
12113	28142	450.00	176.38	273.62
12114	28143	480.00	144.97	335.03
12115	28144	400.00	157.25	242.75
12116	28145	420.00	167.78	252.22
12117	28146	280.00	89.75	190.25
12118	28147	850.00	268.71	581.29
12119	28148	825.00	297.52	527.48
12120	28149	775.00	242.73	532.27
12121	28150	390.00	122.95	267.05
12122	28151	850.00	280.69	569.31
12123	28152	625.00	239.94	385.06
12124	28153	520.00	176.61	343.39
12125	28154	270.00	95.00	175.00
12126	28155	320.00	126.33	193.67
12127	28156	465.00	146.44	318.56
12128	28157	375.00	137.27	237.73
12129	28158	390.00	143.00	247.00
12130	28159	525.00	175.39	349.61
12131	28160	375.00	128.25	246.75
12132	28161	800.00	286.03	513.97
12133	28162	420.00	167.62	252.38
12134	28163	625.00	206.36	418.64
12135	28164	320.00	115.85	204.15
12136	28165	420.00	138.50	281.50
12137	28166	460.00	140.70	319.30
12138	28167	525.00	189.70	335.30
12139	28168	525.00	207.04	317.96
12140	28169	825.00	323.35	501.65
12141	28170	320.00	100.44	219.56
12142	28171	345.00	121.84	223.16
12143	28172	480.00	180.17	299.83
12144	28173	850.00	292.62	557.38
12145	28174	480.00	182.99	297.01
12146	28175	600.00	193.67	406.33
12147	28176	280.00	84.58	195.42
12148	28177	345.00	135.85	209.15
12149	28178	525.00	185.05	339.95
12150	28179	435.00	150.96	284.04
12151	28180	340.00	125.16	214.84
12152	28181	405.00	158.57	246.43
12153	28182	700.00	266.79	433.21
12154	28183	975.00	374.66	600.34
12155	28184	525.00	165.97	359.03
12156	28185	390.00	127.05	262.95
12157	28186	650.00	202.25	447.75
12158	28187	440.00	146.13	293.87
12159	28188	320.00	117.44	202.56
12160	28189	480.00	163.19	316.81
12161	28190	480.00	173.49	306.51
12162	28191	420.00	163.27	256.73
12163	28192	315.00	99.52	215.48
12164	28193	460.00	155.80	304.20
12165	28194	420.00	165.16	254.84
12166	28195	460.00	138.30	321.70
12167	28196	420.00	156.09	263.91
12168	28197	1000.00	375.67	624.33
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.locations (id, driver_id, lat, lng, accuracy, "timestamp") FROM stdin;
1	driver1	-1.31864	36.8352	0	2025-03-21 16:22:32.341805
2	driver1	-1.31864	36.8352	0	2025-03-21 16:24:53.118568
3	driver1	-1.31864	36.8352	0	2025-03-21 16:40:43.972359
4	driver1	-1.32323	36.8802	0	2025-03-21 21:24:52.646751
5	driver1	-1.32323	36.8802	0	2025-03-21 21:25:15.301614
6	driver1	-1.32323	36.8802	0	2025-03-21 21:27:09.109457
7	driver1	-1.32323	36.8802	0	2025-03-21 21:34:42.362822
8	driver1	-1.32323	36.8802	0	2025-03-21 22:19:36.123442
9	driver1	-1.32323	36.8802	0	2025-03-21 22:20:05.605438
10	driver1	-1.32323	36.8802	0	2025-03-22 10:34:42.283755
11	driver1	-1.2841	36.8155	0	2025-03-23 18:31:50.952399
12	driver1	-1.2841	36.8155	0	2025-03-23 18:33:38.323011
13	driver1	-1.2841	36.8155	0	2025-04-02 11:39:40.540976
14	driver1	-1.2841	36.8155	0	2025-04-02 11:40:06.706848
15	driver1	-1.2841	36.8155	0	2025-04-02 13:43:43.77865
16	driver1	-1.32323	36.8802	0	2025-04-10 20:29:31.713923
49	driver1	-4.05466	39.6636	0	2025-04-23 09:37:33.518606
50	driver1	-1.2841	36.8155	0	2025-04-27 22:30:13.645398
51	driver1	0.5177344	35.2944128	0	2025-04-29 10:11:29.409968
52	driver1	-4.05466	39.6636	0	2025-04-29 10:11:31.919936
53	driver1	0.5177344	35.2944128	0	2025-04-29 10:11:32.946857
54	driver1	0.5177344	35.2944128	0	2025-04-29 10:11:38.168821
55	driver1	0.5177344	35.2944128	0	2025-04-29 10:11:43.168744
56	driver1	0.5177344	35.2944128	0	2025-04-29 10:11:48.168889
57	driver1	0.5177344	35.2944128	0	2025-04-29 10:11:53.178231
58	driver1	0.5177344	35.2944128	0	2025-04-29 10:11:58.17799
59	driver1	0.5177344	35.2944128	0	2025-04-29 10:12:03.719022
60	driver1	0.5177344	35.2944128	0	2025-04-29 10:12:08.761478
61	driver1	0.5177344	35.2944128	0	2025-04-29 10:12:13.762247
62	driver1	0.5177344	35.2944128	0	2025-04-29 10:12:18.865967
63	driver1	-4.05466	39.6636	0	2025-04-29 10:12:22.846612
64	driver1	0.5177344	35.2944128	0	2025-04-29 10:12:24.033413
65	driver1	-1.3913847	36.7634501	0	2025-04-29 10:12:28.640461
66	driver1	-1.3913847	36.7634501	0	2025-04-29 10:12:32.964768
67	driver1	-1.3913847	36.7634501	0	2025-04-29 10:12:37.96648
68	driver1	-4.05466	39.6636	0	2025-04-29 10:12:40.547841
69	driver1	-1.3913847	36.7634501	0	2025-04-29 10:12:42.965852
70	driver1	-1.3913847	36.7634501	0	2025-04-29 10:12:47.966114
71	driver1	-1.3913847	36.7634501	0	2025-04-29 10:12:52.966862
72	driver1	-1.3913847	36.7634501	0	2025-04-29 10:12:57.999787
73	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:02.995632
74	driver1	-4.05466	39.6636	0	2025-04-29 10:13:06.412278
75	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:08.099968
76	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:13.121616
77	driver1	-4.05466	39.6636	0	2025-04-29 10:13:17.57611
78	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:18.128905
79	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:23.15833
80	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:27.978886
81	driver1	-4.05466	39.6636	0	2025-04-29 10:13:30.96938
82	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:33.048857
83	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:38.049982
84	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:43.050314
85	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:48.13004
86	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:53.150141
87	driver1	-1.3913847	36.7634501	0	2025-04-29 10:13:58.149139
88	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:03.180754
89	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:08.180972
90	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:13.181532
91	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:18.231284
92	driver1	-4.05466	39.6636	0	2025-04-29 10:14:22.438732
93	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:23.239835
94	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:27.99939
95	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:33.005165
96	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:38.0978
97	driver1	-4.05466	39.6636	0	2025-04-29 10:14:40.93024
98	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:43.055027
99	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:48.100869
100	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:53.156252
101	driver1	-1.3913847	36.7634501	0	2025-04-29 10:14:58.197868
102	driver1	-1.3913847	36.7634501	0	2025-04-29 10:15:03.327399
103	driver1	-1.3913847	36.7634501	0	2025-04-29 10:15:08.326442
104	driver1	-1.3913847	36.7634501	0	2025-04-29 10:15:13.422003
105	driver1	-1.3913847	36.7634501	0	2025-04-29 10:15:18.430139
106	driver1	-1.3913847	36.7634501	0	2025-04-29 10:15:23.443274
107	driver1	-1.3913847	36.7634501	0	2025-04-29 10:15:28.443678
108	driver1	-1.3913844	36.7634569	0	2025-04-29 10:15:30.469082
109	driver1	-1.3913844	36.7634569	0	2025-04-29 10:15:33.67602
110	driver1	-1.3913844	36.7634569	0	2025-04-29 10:15:38.765737
111	driver1	-1.3913844	36.7634569	0	2025-04-29 10:15:43.758875
112	driver1	-1.3913844	36.7634569	0	2025-04-29 10:15:48.796956
113	driver1	-1.3913844	36.7634569	0	2025-04-29 10:15:54.323094
114	driver1	-1.3913844	36.7634569	0	2025-04-29 10:15:59.3241
115	driver1	-4.05466	39.6636	0	2025-04-29 10:16:03.305873
116	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:04.408277
117	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:09.846182
118	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:14.852609
119	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:19.92803
120	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:24.926782
121	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:28.48046
122	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:33.481315
123	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:38.915385
124	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:43.956584
125	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:48.957438
126	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:53.957897
127	driver1	-4.05466	39.6636	0	2025-04-29 10:16:54.973738
128	driver1	-1.3913844	36.7634569	0	2025-04-29 10:16:58.958272
129	driver1	-1.3913844	36.7634569	0	2025-04-29 10:17:04.491359
130	driver1	-1.3913844	36.7634569	0	2025-04-29 10:17:09.492234
131	driver1	-1.3913844	36.7634569	0	2025-04-29 10:17:14.947502
132	driver1	-1.3913844	36.7634569	0	2025-04-29 10:17:19.987347
133	driver1	-1.3913844	36.7634569	0	2025-04-29 10:17:24.987238
134	driver1	-1.3913826	36.7634602	0	2025-04-29 10:17:29.930659
135	driver1	-1.3913826	36.7634602	0	2025-04-29 10:17:33.552665
136	driver1	-1.3913826	36.7634602	0	2025-04-29 10:17:38.555171
137	driver1	-1.3913826	36.7634602	0	2025-04-29 10:17:43.554644
138	driver1	-1.3913826	36.7634602	0	2025-04-29 10:17:48.985247
139	driver1	-1.3913826	36.7634602	0	2025-04-29 10:17:54.075223
140	driver1	-1.3913826	36.7634602	0	2025-04-29 10:17:59.077002
141	driver1	-1.3913826	36.7634602	0	2025-04-29 10:18:04.084976
142	driver1	-4.05466	39.6636	0	2025-04-29 10:18:04.258629
143	driver1	-1.3913826	36.7634602	0	2025-04-29 10:18:09.084524
144	driver1	-1.3913826	36.7634602	0	2025-04-29 10:18:14.086589
145	driver1	-1.3913826	36.7634602	0	2025-04-29 10:18:19.085269
146	driver1	-4.05466	39.6636	0	2025-04-29 10:18:19.219933
147	driver1	-4.05466	39.6636	0	2025-04-29 10:18:23.952506
148	driver1	-1.3913826	36.7634602	0	2025-04-29 10:18:24.125326
149	driver1	-1.391384	36.7634603	0	2025-04-29 10:18:28.757008
150	driver1	-1.391384	36.7634603	0	2025-04-29 10:18:33.582448
151	driver1	-1.391384	36.7634603	0	2025-04-29 10:18:39.041865
152	driver1	-1.391384	36.7634603	0	2025-04-29 10:18:44.106859
153	driver1	-1.391384	36.7634603	0	2025-04-29 10:18:49.106996
154	driver1	-1.391384	36.7634603	0	2025-04-29 10:18:54.107442
155	driver1	-4.05466	39.6636	0	2025-04-29 10:18:55.417656
156	driver1	-1.391384	36.7634603	0	2025-04-29 10:18:59.108058
157	driver1	-1.391384	36.7634603	0	2025-04-29 10:19:04.12602
158	driver1	-1.391384	36.7634603	0	2025-04-29 10:19:09.119796
159	driver1	-4.05466	39.6636	0	2025-04-29 10:19:12.85184
160	driver1	-1.391384	36.7634603	0	2025-04-29 10:19:14.119285
161	driver1	-1.391384	36.7634603	0	2025-04-29 10:19:19.120815
162	driver1	-1.391384	36.7634603	0	2025-04-29 10:19:24.119816
163	driver1	-4.05466	39.6636	0	2025-04-29 10:19:27.624828
164	driver1	-1.3913818	36.7634604	0	2025-04-29 10:19:28.865565
165	driver1	-1.3913818	36.7634604	0	2025-04-29 10:19:33.714793
166	driver1	-1.3913818	36.7634604	0	2025-04-29 10:19:38.717072
167	driver1	-1.3913818	36.7634604	0	2025-04-29 10:19:43.715983
168	driver1	-1.3913818	36.7634604	0	2025-04-29 10:19:49.173165
169	driver1	-1.3913818	36.7634604	0	2025-04-29 10:19:54.190801
170	driver1	-4.05466	39.6636	0	2025-04-29 10:19:58.624953
171	driver1	-1.3913818	36.7634604	0	2025-04-29 10:19:59.198379
172	driver1	-1.3913818	36.7634604	0	2025-04-29 10:20:04.204233
173	driver1	-1.3913818	36.7634604	0	2025-04-29 10:20:09.203806
174	driver1	-4.05466	39.6636	0	2025-04-29 10:20:13.652521
175	driver1	-1.3913818	36.7634604	0	2025-04-29 10:20:14.226567
176	driver1	-1.3913818	36.7634604	0	2025-04-29 10:20:19.227023
177	driver1	-1.3913818	36.7634604	0	2025-04-29 10:20:24.227473
178	driver1	-1.39138	36.7634578	0	2025-04-29 10:20:29.021064
179	driver1	-1.39138	36.7634578	0	2025-04-29 10:20:33.752817
180	driver1	-1.39138	36.7634578	0	2025-04-29 10:20:38.753333
181	driver1	-1.39138	36.7634578	0	2025-04-29 10:20:43.753671
182	driver1	-4.05466	39.6636	0	2025-04-29 10:20:46.402133
183	driver1	-1.39138	36.7634578	0	2025-04-29 10:20:49.091478
184	driver1	-1.39138	36.7634578	0	2025-04-29 10:20:54.091751
185	driver1	-1.39138	36.7634578	0	2025-04-29 10:20:59.248548
186	driver1	-4.05466	39.6636	0	2025-04-29 10:21:01.773371
187	driver1	-1.39138	36.7634578	0	2025-04-29 10:21:04.478743
188	driver1	-1.39138	36.7634578	0	2025-04-29 10:21:09.508838
189	driver1	-1.39138	36.7634578	0	2025-04-29 10:21:14.513524
190	driver1	-1.39138	36.7634578	0	2025-04-29 10:21:19.51172
191	driver1	-1.39138	36.7634578	0	2025-04-29 10:21:24.510006
192	driver1	-1.3913821	36.7634613	0	2025-04-29 10:21:29.606794
193	driver1	-1.3913821	36.7634613	0	2025-04-29 10:21:34.340142
194	driver1	-4.05466	39.6636	0	2025-04-29 10:21:35.731789
195	driver1	-1.3913821	36.7634613	0	2025-04-29 10:21:39.340431
196	driver1	-1.3913821	36.7634613	0	2025-04-29 10:21:44.341562
197	driver1	-1.3913821	36.7634613	0	2025-04-29 10:21:49.344258
198	driver1	-4.05466	39.6636	0	2025-04-29 10:21:51.715494
199	driver1	-1.3913821	36.7634613	0	2025-04-29 10:21:54.341624
200	driver1	-1.3913821	36.7634613	0	2025-04-29 10:21:59.350069
201	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:04.478907
202	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:09.472996
203	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:14.473317
204	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:19.473419
205	driver1	-4.05466	39.6636	0	2025-04-29 10:22:22.66806
206	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:24.474141
207	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:29.366641
208	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:34.360238
209	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:39.363626
210	driver1	-4.05466	39.6636	0	2025-04-29 10:22:40.74066
211	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:44.361792
212	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:49.44423
213	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:54.445285
214	driver1	-1.3913821	36.7634613	0	2025-04-29 10:22:59.444853
215	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:04.482799
216	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:09.473495
217	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:14.473844
218	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:19.642752
219	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:24.642833
220	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:29.909417
221	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:29.925654
222	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:35.204896
223	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:40.206319
224	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:45.660327
225	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:50.661657
226	driver1	-4.05466	39.6636	0	2025-04-29 10:23:50.798042
227	driver1	-1.3913821	36.7634613	0	2025-04-29 10:23:55.661293
228	driver1	-1.3913821	36.7634613	0	2025-04-29 10:24:00.661572
229	driver1	-1.3913821	36.7634613	0	2025-04-29 10:24:05.85887
230	driver1	-1.3913821	36.7634613	0	2025-04-29 10:24:10.857581
231	driver1	-1.3913821	36.7634613	0	2025-04-29 10:24:15.858075
232	driver1	-1.3913821	36.7634613	0	2025-04-29 10:24:21.30597
233	driver1	-4.05466	39.6636	0	2025-04-29 10:24:24.23315
234	driver1	-1.3913821	36.7634613	0	2025-04-29 10:24:26.31014
235	driver1	-1.3913767	36.7634581	0	2025-04-29 10:24:31.148199
236	driver1	-1.3913767	36.7634581	0	2025-04-29 10:24:35.725808
237	driver1	-1.3913767	36.7634581	0	2025-04-29 10:24:40.726711
238	driver1	-4.05466	39.6636	0	2025-04-29 10:24:41.443452
239	driver1	-1.3913767	36.7634581	0	2025-04-29 10:24:46.209128
240	driver1	-1.3913767	36.7634581	0	2025-04-29 10:24:51.724787
241	driver1	-1.3913767	36.7634581	0	2025-04-29 10:24:56.72462
242	driver1	-4.05466	39.6636	0	2025-04-29 10:25:01.943505
243	driver1	-1.3913767	36.7634581	0	2025-04-29 10:25:01.948841
244	driver1	-1.3913767	36.7634581	0	2025-04-29 10:25:06.951794
245	driver1	-1.3913767	36.7634581	0	2025-04-29 10:25:11.952662
246	driver1	-1.3913767	36.7634581	0	2025-04-29 10:25:16.952786
247	driver1	-4.05466	39.6636	0	2025-04-29 10:25:19.02398
248	driver1	-1.3913767	36.7634581	0	2025-04-29 10:25:21.954765
249	driver1	-1.3913767	36.7634581	0	2025-04-29 10:25:27.352109
250	driver1	-1.3913837	36.7634516	0	2025-04-29 10:25:32.057508
251	driver1	-4.05466	39.6636	0	2025-04-29 10:25:34.862938
252	driver1	-1.3913837	36.7634516	0	2025-04-29 10:25:35.755675
253	driver1	-1.3913837	36.7634516	0	2025-04-29 10:25:40.756337
254	driver1	-1.3913837	36.7634516	0	2025-04-29 10:25:45.756909
255	driver1	-4.05466	39.6636	0	2025-04-29 10:25:50.166879
256	driver1	-1.3913837	36.7634516	0	2025-04-29 10:25:50.757656
257	driver1	-1.3913837	36.7634516	0	2025-04-29 10:25:55.798693
258	driver1	-1.3913837	36.7634516	0	2025-04-29 10:26:01.386187
259	driver1	-4.05466	39.6636	0	2025-04-29 10:26:06.109767
260	driver1	-1.3913837	36.7634516	0	2025-04-29 10:26:06.506687
261	driver1	-1.3913837	36.7634516	0	2025-04-29 10:26:11.464021
262	driver1	-1.3913837	36.7634516	0	2025-04-29 10:26:16.58737
263	driver1	-1.3913837	36.7634516	0	2025-04-29 10:26:21.843224
264	driver1	-4.05466	39.6636	0	2025-04-29 10:26:23.627327
265	driver1	-1.3913837	36.7634516	0	2025-04-29 10:26:26.839625
266	driver1	0.5177344	35.2944128	0	2025-04-29 10:26:31.079144
267	driver1	0.5177344	35.2944128	0	2025-04-29 10:26:36.153128
268	driver1	0.5177344	35.2944128	0	2025-04-29 10:26:41.153708
269	driver1	0.5177344	35.2944128	0	2025-04-29 10:26:46.154097
270	driver1	0.5177344	35.2944128	0	2025-04-29 10:26:51.159196
271	driver1	0.5177344	35.2944128	0	2025-04-29 10:26:56.158662
272	driver1	-4.05466	39.6636	0	2025-04-29 10:26:56.215302
273	driver1	0.5177344	35.2944128	0	2025-04-29 10:27:01.159181
274	driver1	0.5177344	35.2944128	0	2025-04-29 10:27:06.175248
275	driver1	0.5177344	35.2944128	0	2025-04-29 10:27:11.275146
276	driver1	0.5177344	35.2944128	0	2025-04-29 10:27:16.457878
277	driver1	0.5177344	35.2944128	0	2025-04-29 10:27:21.455397
278	driver1	0.5177344	35.2944128	0	2025-04-29 10:27:26.764524
279	driver1	0.5177344	35.2944128	0	2025-04-29 10:27:31.832025
280	driver1	-1.3913866	36.7634502	0	2025-04-29 10:27:32.676244
281	driver1	-1.3913866	36.7634502	0	2025-04-29 10:27:36.851817
282	driver1	-1.3913866	36.7634502	0	2025-04-29 10:27:42.283418
283	driver1	-1.3913866	36.7634502	0	2025-04-29 10:27:47.27842
284	driver1	-4.05466	39.6636	0	2025-04-29 10:27:47.9912
285	driver1	-1.3913866	36.7634502	0	2025-04-29 10:27:52.277371
286	driver1	-1.3913866	36.7634502	0	2025-04-29 10:27:57.276577
287	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:02.277722
288	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:07.289823
289	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:12.285238
290	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:17.342907
291	driver1	-4.05466	39.6636	0	2025-04-29 10:28:19.039395
292	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:22.343098
293	driver1	-4.05466	39.6636	0	2025-04-29 10:28:23.95241
294	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:27.343552
295	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:31.892463
296	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:36.892363
297	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:41.983856
298	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:46.984618
299	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:51.993423
300	driver1	-1.3913866	36.7634502	0	2025-04-29 10:28:56.994223
301	driver1	-1.3913866	36.7634502	0	2025-04-29 10:29:01.994791
302	driver1	-1.3913866	36.7634502	0	2025-04-29 10:29:07.292795
303	driver1	-4.05466	39.6636	0	2025-04-29 10:29:10.855807
304	driver1	-1.3913866	36.7634502	0	2025-04-29 10:29:12.318949
305	driver1	-1.3913866	36.7634502	0	2025-04-29 10:29:17.316059
306	driver1	-1.3913866	36.7634502	0	2025-04-29 10:29:22.31874
307	driver1	-1.3913866	36.7634502	0	2025-04-29 10:29:27.313724
308	driver1	-1.3913849	36.7634558	0	2025-04-29 10:29:32.245998
309	driver1	-1.3913849	36.7634558	0	2025-04-29 10:29:37.092443
310	driver1	-4.05466	39.6636	0	2025-04-29 10:29:40.638842
311	driver1	-1.3913849	36.7634558	0	2025-04-29 10:29:42.12045
312	driver1	-1.3913849	36.7634558	0	2025-04-29 10:29:47.121436
313	driver1	-1.3913849	36.7634558	0	2025-04-29 10:29:52.135932
314	driver1	-4.05466	39.6636	0	2025-04-29 10:29:55.686226
315	driver1	-1.3913849	36.7634558	0	2025-04-29 10:29:57.177272
316	driver1	-1.3913849	36.7634558	0	2025-04-29 10:30:02.178546
317	driver1	-1.3913849	36.7634558	0	2025-04-29 10:30:07.297744
318	driver1	-1.3913849	36.7634558	0	2025-04-29 10:30:12.296158
319	driver1	-1.3913849	36.7634558	0	2025-04-29 10:30:17.558184
320	driver1	-1.3913849	36.7634558	0	2025-04-29 10:30:22.549498
321	driver1	-1.3913849	36.7634558	0	2025-04-29 10:30:27.549847
322	driver1	-1.3913849	36.7634558	0	2025-04-29 10:30:32.550894
323	driver1	-1.3913826	36.76346	0	2025-04-29 10:30:32.726835
324	driver1	-1.3913826	36.76346	0	2025-04-29 10:30:37.566093
325	driver1	-4.05466	39.6636	0	2025-04-29 10:30:41.720223
326	driver1	-1.3913826	36.76346	0	2025-04-29 10:30:42.803118
327	driver1	-1.3913826	36.76346	0	2025-04-29 10:30:47.797594
328	driver1	-1.3913826	36.76346	0	2025-04-29 10:30:52.797979
329	driver1	-1.3913826	36.76346	0	2025-04-29 10:30:58.15653
330	driver1	-1.3913826	36.76346	0	2025-04-29 10:31:03.157088
331	driver1	-1.3913826	36.76346	0	2025-04-29 10:31:08.157521
332	driver1	-1.3913826	36.76346	0	2025-04-29 10:31:13.171227
333	driver1	-4.05466	39.6636	0	2025-04-29 10:31:15.685246
334	driver1	-1.3913826	36.76346	0	2025-04-29 10:31:18.194091
335	driver1	-1.3913826	36.76346	0	2025-04-29 10:31:23.193857
336	driver1	-1.3913826	36.76346	0	2025-04-29 10:31:28.194081
337	driver1	-4.05466	39.6636	0	2025-04-29 10:31:31.645322
338	driver1	-1.3913801	36.7634587	0	2025-04-29 10:31:32.968651
339	driver1	-1.3913801	36.7634587	0	2025-04-29 10:31:37.768734
340	driver1	-1.3913801	36.7634587	0	2025-04-29 10:31:43.192252
341	driver1	-1.3913801	36.7634587	0	2025-04-29 10:31:48.206313
342	driver1	-1.3913801	36.7634587	0	2025-04-29 10:31:53.21836
343	driver1	-1.3913801	36.7634587	0	2025-04-29 10:31:58.220812
344	driver1	-1.3913801	36.7634587	0	2025-04-29 10:32:03.232135
345	driver1	-4.05466	39.6636	0	2025-04-29 10:32:03.830389
346	driver1	-1.3913801	36.7634587	0	2025-04-29 10:32:08.230674
347	driver1	-1.3913801	36.7634587	0	2025-04-29 10:32:13.240009
348	driver1	-1.3913801	36.7634587	0	2025-04-29 10:32:18.240149
349	driver1	-1.3913801	36.7634587	0	2025-04-29 10:32:23.241476
350	driver1	-1.3913801	36.7634587	0	2025-04-29 10:32:28.241272
351	driver1	-1.3913765	36.7634593	0	2025-04-29 10:32:32.97573
352	driver1	-1.3913765	36.7634593	0	2025-04-29 10:32:37.76888
353	driver1	-1.3913765	36.7634593	0	2025-04-29 10:32:42.769312
354	driver1	-1.3913765	36.7634593	0	2025-04-29 10:32:48.295814
355	driver1	-1.3913765	36.7634593	0	2025-04-29 10:32:53.290624
356	driver1	-1.3913765	36.7634593	0	2025-04-29 10:32:58.29711
357	driver1	-1.3913765	36.7634593	0	2025-04-29 10:33:03.298442
358	driver1	-4.05466	39.6636	0	2025-04-29 10:33:06.798409
359	driver1	-1.3913765	36.7634593	0	2025-04-29 10:33:08.363519
360	driver1	-1.3913765	36.7634593	0	2025-04-29 10:33:13.388161
361	driver1	-4.05466	39.6636	0	2025-04-29 10:33:15.619319
362	driver1	-1.3913765	36.7634593	0	2025-04-29 10:33:18.416973
363	driver1	-1.3913765	36.7634593	0	2025-04-29 10:33:23.427484
364	driver1	-1.3913765	36.7634593	0	2025-04-29 10:33:28.426201
365	driver1	-1.3913765	36.7634593	0	2025-04-29 10:33:33.451272
366	driver1	-1.3913814	36.7634609	0	2025-04-29 10:33:33.906864
367	driver1	-1.3913814	36.7634609	0	2025-04-29 10:33:39.045656
368	driver1	-1.3913814	36.7634609	0	2025-04-29 10:33:44.068244
369	driver1	-1.3913814	36.7634609	0	2025-04-29 10:33:49.06758
370	driver1	-1.3913814	36.7634609	0	2025-04-29 10:33:54.068245
371	driver1	-1.3913814	36.7634609	0	2025-04-29 10:33:59.475647
372	driver1	-4.05466	39.6636	0	2025-04-29 10:33:59.642913
373	driver1	-1.3913814	36.7634609	0	2025-04-29 10:34:05.084345
374	driver1	-1.3913814	36.7634609	0	2025-04-29 10:34:10.51953
375	driver1	-1.3913814	36.7634609	0	2025-04-29 10:34:15.519522
376	driver1	-1.3913814	36.7634609	0	2025-04-29 10:34:20.520092
377	driver1	-1.3913814	36.7634609	0	2025-04-29 10:34:25.521185
378	driver1	-1.3913814	36.7634609	0	2025-04-29 10:34:30.521751
379	driver1	-1.3913828	36.7634556	0	2025-04-29 10:34:33.789438
380	driver1	-1.3913828	36.7634556	0	2025-04-29 10:34:38.633781
381	driver1	-1.3913828	36.7634556	0	2025-04-29 10:34:43.633825
382	driver1	-4.05466	39.6636	0	2025-04-29 10:34:43.733691
383	driver1	-1.3913828	36.7634556	0	2025-04-29 10:34:48.634396
384	driver1	-1.3913828	36.7634556	0	2025-04-29 10:34:53.634775
385	driver1	-1.3913828	36.7634556	0	2025-04-29 10:34:58.635061
386	driver1	-4.05466	39.6636	0	2025-04-29 10:34:59.659769
387	driver1	-1.3913828	36.7634556	0	2025-04-29 10:35:04.127423
388	driver1	-1.3913828	36.7634556	0	2025-04-29 10:35:09.127763
389	driver1	-1.3913828	36.7634556	0	2025-04-29 10:35:14.127957
390	driver1	-1.3913828	36.7634556	0	2025-04-29 10:35:19.12841
391	driver1	-1.3913828	36.7634556	0	2025-04-29 10:35:24.129072
392	driver1	-1.3913828	36.7634556	0	2025-04-29 10:35:29.129442
393	driver1	-4.05466	39.6636	0	2025-04-29 10:35:30.658848
394	driver1	-1.3913789	36.763453	0	2025-04-29 10:35:34.002224
395	driver1	-1.3913789	36.763453	0	2025-04-29 10:35:38.844849
396	driver1	-1.3913789	36.763453	0	2025-04-29 10:35:43.846268
397	driver1	-4.05466	39.6636	0	2025-04-29 10:35:45.787034
398	driver1	-1.3913789	36.763453	0	2025-04-29 10:35:48.849094
399	driver1	-1.3913789	36.763453	0	2025-04-29 10:35:53.848569
400	driver1	-1.3913789	36.763453	0	2025-04-29 10:35:58.848021
401	driver1	-4.05466	39.6636	0	2025-04-29 10:35:59.592618
402	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:04.114708
403	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:09.286695
404	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:14.506486
405	driver1	-4.05466	39.6636	0	2025-04-29 10:36:14.651764
406	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:19.501235
407	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:24.501418
408	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:29.502142
409	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:34.012353
410	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:39.012974
411	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:44.013194
412	driver1	-4.05466	39.6636	0	2025-04-29 10:36:44.828801
413	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:49.013842
414	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:54.013876
415	driver1	-4.05466	39.6636	0	2025-04-29 10:36:58.620883
416	driver1	-1.3913789	36.763453	0	2025-04-29 10:36:59.021885
417	driver1	-1.3913789	36.763453	0	2025-04-29 10:37:04.035428
418	driver1	-1.3913789	36.763453	0	2025-04-29 10:37:09.139073
419	driver1	-4.05466	39.6636	0	2025-04-29 10:37:13.62754
420	driver1	-1.3913789	36.763453	0	2025-04-29 10:37:14.12739
421	driver1	-1.3913789	36.763453	0	2025-04-29 10:37:19.136283
422	driver1	-1.3913789	36.763453	0	2025-04-29 10:37:24.145421
423	driver1	-1.3913789	36.763453	0	2025-04-29 10:37:29.1464
424	driver1	-1.3913789	36.763453	0	2025-04-29 10:37:34.142705
425	driver1	-1.3913838	36.7634538	0	2025-04-29 10:37:34.448311
426	driver1	-1.3913838	36.7634538	0	2025-04-29 10:37:39.262304
427	driver1	-1.3913838	36.7634538	0	2025-04-29 10:37:44.783231
428	driver1	-1.3913838	36.7634538	0	2025-04-29 10:37:49.783201
429	driver1	-1.3913838	36.7634538	0	2025-04-29 10:37:54.783708
430	driver1	-1.3913838	36.7634538	0	2025-04-29 10:37:59.789388
431	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:04.800695
432	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:10.028879
433	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:15.028657
434	driver1	-4.05466	39.6636	0	2025-04-29 10:38:16.628666
435	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:20.132647
436	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:25.510762
437	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:30.511545
438	driver1	-4.05466	39.6636	0	2025-04-29 10:38:31.636667
439	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:34.264276
440	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:39.263099
441	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:44.263294
442	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:49.26376
443	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:54.26447
444	driver1	-1.3913838	36.7634538	0	2025-04-29 10:38:59.768344
445	driver1	-4.05466	39.6636	0	2025-04-29 10:39:03.1028
446	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:04.776799
447	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:09.786847
448	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:14.784352
449	driver1	-4.05466	39.6636	0	2025-04-29 10:39:18.611745
450	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:19.798858
451	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:24.872643
452	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:29.906031
453	driver1	-4.05466	39.6636	0	2025-04-29 10:39:32.89671
454	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:34.307149
455	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:39.759091
456	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:44.760995
457	driver1	-4.05466	39.6636	0	2025-04-29 10:39:47.6017
458	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:49.759968
459	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:54.760691
460	driver1	-1.3913838	36.7634538	0	2025-04-29 10:39:59.90422
461	driver1	-4.05466	39.6636	0	2025-04-29 10:40:02.593286
462	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:04.904849
463	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:09.911582
464	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:14.923732
465	driver1	-4.05466	39.6636	0	2025-04-29 10:40:17.606386
466	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:20.499944
467	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:25.946087
468	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:31.552725
469	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:35.962265
470	driver1	-4.05466	39.6636	0	2025-04-29 10:40:42.577542
471	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:46.133708
472	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:51.282345
473	driver1	-1.3913838	36.7634538	0	2025-04-29 10:40:56.373167
474	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:01.224341
475	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:06.224637
476	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:11.225045
477	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:16.796399
478	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:21.858189
479	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:26.840377
480	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:31.898724
481	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:35.987952
482	driver1	-4.05466	39.6636	0	2025-04-29 10:41:36.822112
483	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:40.988254
484	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:45.988468
485	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:51.410244
486	driver1	-4.05466	39.6636	0	2025-04-29 10:41:53.219828
487	driver1	-1.3913838	36.7634538	0	2025-04-29 10:41:56.282588
488	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:01.28725
489	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:06.48722
490	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:11.507828
491	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:16.513616
492	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:21.836009
493	driver1	-4.05466	39.6636	0	2025-04-29 10:42:24.743245
494	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:26.918387
495	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:32.069364
496	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:36.149982
497	driver1	-4.05466	39.6636	0	2025-04-29 10:42:39.73259
498	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:41.224498
499	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:46.224522
500	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:51.471738
501	driver1	-1.3913838	36.7634538	0	2025-04-29 10:42:56.741637
502	driver1	-4.05466	39.6636	0	2025-04-29 10:42:56.941845
503	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:01.740997
504	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:07.321587
505	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:12.582687
506	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:17.971908
507	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:22.972053
508	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:28.481324
509	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:33.879119
510	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:36.165285
511	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:41.172144
512	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:46.166862
513	driver1	-4.05466	39.6636	0	2025-04-29 10:43:49.701908
514	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:51.185294
515	driver1	-1.3913838	36.7634538	0	2025-04-29 10:43:56.665533
516	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:02.034244
517	driver1	-4.05466	39.6636	0	2025-04-29 10:44:04.749907
518	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:07.151032
519	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:12.157192
520	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:17.426717
521	driver1	-4.05466	39.6636	0	2025-04-29 10:44:20.888887
522	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:22.467532
523	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:27.749641
524	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:32.750512
525	driver1	-4.05466	39.6636	0	2025-04-29 10:44:36.210141
526	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:36.238384
527	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:41.238543
528	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:46.239034
529	driver1	-4.05466	39.6636	0	2025-04-29 10:44:50.671146
530	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:51.285527
531	driver1	-1.3913838	36.7634538	0	2025-04-29 10:44:56.299708
532	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:01.300224
533	driver1	-4.05466	39.6636	0	2025-04-29 10:45:05.664234
534	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:06.344185
535	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:11.841373
536	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:16.846778
537	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:22.005749
538	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:27.007237
539	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:32.006557
540	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:36.314175
541	driver1	-4.05466	39.6636	0	2025-04-29 10:45:36.649158
542	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:41.394836
543	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:46.39559
544	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:51.396087
545	driver1	-1.3913838	36.7634538	0	2025-04-29 10:45:56.810313
546	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:02.100098
547	driver1	-4.05466	39.6636	0	2025-04-29 10:46:05.590626
548	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:07.168509
549	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:12.276066
550	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:17.277619
551	driver1	-4.05466	39.6636	0	2025-04-29 10:46:20.61333
552	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:22.307229
553	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:27.305654
554	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:32.307324
555	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:36.418243
556	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:41.416037
557	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:46.416016
558	driver1	-4.05466	39.6636	0	2025-04-29 10:46:51.597876
559	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:51.602944
560	driver1	-1.3913838	36.7634538	0	2025-04-29 10:46:56.598739
561	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:01.848185
562	driver1	-4.05466	39.6636	0	2025-04-29 10:47:06.596638
563	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:06.861887
564	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:11.861724
565	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:16.866253
566	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:21.863312
567	driver1	-4.05466	39.6636	0	2025-04-29 10:47:22.776602
568	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:26.870245
569	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:31.868334
570	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:36.865514
571	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:36.882344
572	driver1	-4.05466	39.6636	0	2025-04-29 10:47:36.949517
573	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:41.883168
574	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:46.96018
575	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:51.961916
576	driver1	-1.3913838	36.7634538	0	2025-04-29 10:47:56.974685
577	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:01.977151
578	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:07.44193
579	driver1	-4.05466	39.6636	0	2025-04-29 10:48:07.658539
580	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:12.621828
581	driver1	-4.05466	39.6636	0	2025-04-29 10:48:16.689757
582	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:17.765398
583	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:22.847293
584	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:27.927259
585	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:33.024785
586	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:37.127705
587	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:42.21725
588	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:47.221202
589	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:52.220246
590	driver1	-1.3913838	36.7634538	0	2025-04-29 10:48:57.218758
591	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:02.240605
592	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:07.234277
593	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:12.534844
594	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:17.540095
595	driver1	-4.05466	39.6636	0	2025-04-29 10:49:19.729936
596	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:22.727823
597	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:27.727517
598	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:32.728102
599	driver1	-4.05466	39.6636	0	2025-04-29 10:49:36.789318
600	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:37.191364
601	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:42.192371
602	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:47.292142
603	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:52.292327
604	driver1	-1.3913838	36.7634538	0	2025-04-29 10:49:57.715698
605	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:02.715989
606	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:07.718155
607	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:13.087728
608	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:18.088291
609	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:23.08872
610	driver1	-4.05466	39.6636	0	2025-04-29 10:50:24.030363
611	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:28.089112
612	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:33.08994
613	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:37.218443
614	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:42.218821
615	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:47.219651
616	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:52.220246
617	driver1	-1.3913838	36.7634538	0	2025-04-29 10:50:57.229174
618	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:02.229262
619	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:07.336075
620	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:12.309871
621	driver1	-4.05466	39.6636	0	2025-04-29 10:51:17.113099
622	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:17.316171
623	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:22.415584
624	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:27.416103
625	driver1	-4.05466	39.6636	0	2025-04-29 10:51:32.109534
626	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:32.421763
627	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:37.422331
628	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:37.440304
629	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:42.441087
630	driver1	-4.05466	39.6636	0	2025-04-29 10:51:46.689762
631	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:47.459084
632	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:52.459458
633	driver1	-1.3913838	36.7634538	0	2025-04-29 10:51:57.459911
634	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:02.527354
635	driver1	-4.05466	39.6636	0	2025-04-29 10:52:02.796886
636	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:07.786372
637	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:12.865839
638	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:17.86623
639	driver1	-4.05466	39.6636	0	2025-04-29 10:52:17.982583
640	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:22.866803
641	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:27.867039
642	driver1	-4.05466	39.6636	0	2025-04-29 10:52:32.774198
643	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:32.877675
644	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:37.877813
645	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:37.892084
646	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:42.892951
647	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:48.262281
648	driver1	-4.05466	39.6636	0	2025-04-29 10:52:49.04903
649	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:53.58605
650	driver1	-1.3913838	36.7634538	0	2025-04-29 10:52:58.586716
651	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:04.032261
652	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:09.348914
653	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:14.624705
654	driver1	-4.05466	39.6636	0	2025-04-29 10:53:15.77078
655	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:19.71994
656	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:24.826951
657	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:30.344388
658	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:35.62141
659	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:38.772084
660	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:43.774936
661	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:48.798109
662	driver1	-4.05466	39.6636	0	2025-04-29 10:53:51.6161
663	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:53.944834
664	driver1	-1.3913838	36.7634538	0	2025-04-29 10:53:58.942457
665	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:03.94583
666	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:08.943781
667	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:14.163596
668	driver1	-4.05466	39.6636	0	2025-04-29 10:54:17.875892
669	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:19.178842
670	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:24.783638
671	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:29.787092
672	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:34.786686
673	driver1	-4.05466	39.6636	0	2025-04-29 10:54:35.938109
674	driver1	-4.05466	39.6636	0	2025-04-29 10:54:36.389556
675	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:38.889776
676	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:44.156411
677	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:49.710812
678	driver1	-1.3913838	36.7634538	0	2025-04-29 10:54:54.977076
679	driver1	-1.3913838	36.7634538	0	2025-04-29 10:55:00.351075
680	driver1	-4.05466	39.6636	0	2025-04-29 10:55:03.619922
681	driver1	-1.3913838	36.7634538	0	2025-04-29 10:55:05.401083
682	driver1	-1.3913838	36.7634538	0	2025-04-29 10:55:10.402109
683	driver1	-1.3913838	36.7634538	0	2025-04-29 10:55:15.711151
684	driver1	-1.3913838	36.7634538	0	2025-04-29 10:55:20.712981
685	driver1	-1.3913838	36.7634538	0	2025-04-29 10:55:29.827607
686	driver1	-1.3913838	36.7634538	0	2025-04-29 11:02:34.862981
687	driver1	-1.3913838	36.7634538	0	2025-04-29 11:02:39.252132
688	driver1	-4.05466	39.6636	0	2025-04-29 11:02:39.930541
689	driver1	-1.3913838	36.7634538	0	2025-04-29 11:02:45.131298
690	driver1	-1.3913838	36.7634538	0	2025-04-29 11:02:50.121266
691	driver1	-1.3913838	36.7634538	0	2025-04-29 11:02:55.132087
692	driver1	-1.3913838	36.7634538	0	2025-04-29 11:03:00.162726
693	driver1	-1.3913838	36.7634538	0	2025-04-29 11:03:05.186505
694	driver1	-4.05466	39.6636	0	2025-04-29 11:03:09.319095
695	driver1	-1.3913838	36.7634538	0	2025-04-29 11:03:10.227826
696	driver1	-1.3913838	36.7634538	0	2025-04-29 11:03:15.229188
697	driver1	-4.05466	39.6636	0	2025-04-29 11:03:19.585073
698	driver1	-1.3913838	36.7634538	0	2025-04-29 11:03:20.250767
699	driver1	-1.3913838	36.7634538	0	2025-04-29 11:03:25.251054
700	driver1	-1.3913838	36.7634538	0	2025-04-29 11:03:30.252334
701	driver1	-1.3913838	36.7634538	0	2025-04-29 11:03:35.25295
702	driver1	-1.3913838	36.7634538	0	2025-04-29 11:03:44.333519
703	driver1	-1.3913923	36.7634533	0	2025-04-29 11:03:46.582328
704	driver1	-1.3913923	36.7634533	0	2025-04-29 11:03:49.341754
705	driver1	-1.3913923	36.7634533	0	2025-04-29 11:03:54.372109
706	driver1	-1.3913923	36.7634533	0	2025-04-29 11:03:59.383649
707	driver1	-1.3913923	36.7634533	0	2025-04-29 11:04:04.390091
708	driver1	-4.05466	39.6636	0	2025-04-29 11:04:06.138246
709	driver1	-1.3913923	36.7634533	0	2025-04-29 11:04:09.424597
710	driver1	-1.3913923	36.7634533	0	2025-04-29 11:04:14.436547
711	driver1	-1.3913923	36.7634533	0	2025-04-29 11:04:19.455349
712	driver1	-1.3913923	36.7634533	0	2025-04-29 11:04:24.455856
713	driver1	-1.3913923	36.7634533	0	2025-04-29 11:04:29.456297
714	driver1	-1.3913923	36.7634533	0	2025-04-29 11:04:34.497428
715	driver1	-1.3913812	36.7634542	0	2025-04-29 11:04:39.687471
716	driver1	-4.05466	39.6636	0	2025-04-29 11:04:41.378334
717	driver1	-1.3913812	36.7634542	0	2025-04-29 11:04:44.331976
718	driver1	-1.3913812	36.7634542	0	2025-04-29 11:04:49.344525
719	driver1	-1.3913812	36.7634542	0	2025-04-29 11:04:54.345846
720	driver1	-4.05466	39.6636	0	2025-04-29 11:04:56.328016
721	driver1	-1.3913812	36.7634542	0	2025-04-29 11:04:59.345653
722	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:04.346023
723	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:09.389004
724	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:14.389496
725	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:19.39018
726	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:24.390016
727	driver1	-4.05466	39.6636	0	2025-04-29 11:05:28.08543
728	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:29.445454
729	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:34.445284
730	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:39.405135
731	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:44.405468
732	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:49.427112
733	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:54.42784
734	driver1	-1.3913812	36.7634542	0	2025-04-29 11:05:59.428383
735	driver1	-1.3913812	36.7634542	0	2025-04-29 11:06:04.428744
736	driver1	-1.3913812	36.7634542	0	2025-04-29 11:06:09.469709
737	driver1	-1.3913812	36.7634542	0	2025-04-29 11:06:14.481921
738	driver1	-4.05466	39.6636	0	2025-04-29 11:06:15.968198
739	driver1	-1.3913812	36.7634542	0	2025-04-29 11:06:19.486395
740	driver1	-4.05466	39.6636	0	2025-04-29 11:06:20.706601
741	driver1	-1.3913812	36.7634542	0	2025-04-29 11:06:24.483089
742	driver1	-1.3913812	36.7634542	0	2025-04-29 11:06:29.483546
743	driver1	-1.3913812	36.7634542	0	2025-04-29 11:06:34.507593
744	driver1	-4.05466	39.6636	0	2025-04-29 11:06:35.734553
745	driver1	-1.3913813	36.7634579	0	2025-04-29 11:06:39.738452
746	driver1	-1.3913813	36.7634579	0	2025-04-29 11:06:44.493802
747	driver1	-1.3913813	36.7634579	0	2025-04-29 11:06:49.49407
748	driver1	-4.05466	39.6636	0	2025-04-29 11:06:50.13549
749	driver1	-1.3913813	36.7634579	0	2025-04-29 11:06:54.494664
750	driver1	-1.3913813	36.7634579	0	2025-04-29 11:06:59.494871
751	driver1	-1.3913813	36.7634579	0	2025-04-29 11:07:04.495423
752	driver1	-1.3913813	36.7634579	0	2025-04-29 11:07:09.553128
753	driver1	-1.3913813	36.7634579	0	2025-04-29 11:07:14.563704
754	driver1	-1.3913813	36.7634579	0	2025-04-29 11:07:19.564243
755	driver1	-4.05466	39.6636	0	2025-04-29 11:07:22.643466
756	driver1	-1.3913813	36.7634579	0	2025-04-29 11:07:24.564866
757	driver1	-1.3913813	36.7634579	0	2025-04-29 11:07:29.565072
758	driver1	-1.3913813	36.7634579	0	2025-04-29 11:07:34.56642
759	driver1	-1.3913846	36.7634553	0	2025-04-29 11:07:39.80487
760	driver1	-1.3913846	36.7634553	0	2025-04-29 11:07:44.528905
761	driver1	-1.3913846	36.7634553	0	2025-04-29 11:07:49.529583
762	driver1	-1.3913846	36.7634553	0	2025-04-29 11:07:54.529763
763	driver1	-4.05466	39.6636	0	2025-04-29 11:07:56.866421
764	driver1	-1.3913846	36.7634553	0	2025-04-29 11:07:59.530225
765	driver1	-1.3913846	36.7634553	0	2025-04-29 11:08:04.530712
766	driver1	-1.3913846	36.7634553	0	2025-04-29 11:08:09.585297
767	driver1	-4.05466	39.6636	0	2025-04-29 11:08:12.684348
768	driver1	-1.3913846	36.7634553	0	2025-04-29 11:08:14.585907
769	driver1	-1.3913846	36.7634553	0	2025-04-29 11:08:19.586345
770	driver1	-1.3913846	36.7634553	0	2025-04-29 11:08:24.587017
771	driver1	-1.3913846	36.7634553	0	2025-04-29 11:08:29.587647
772	driver1	-4.05466	39.6636	0	2025-04-29 11:08:30.348862
773	driver1	-1.3913846	36.7634553	0	2025-04-29 11:08:34.589166
774	driver1	-1.3913846	36.7634553	0	2025-04-29 11:08:39.600027
775	driver1	-1.3913851	36.7634559	0	2025-04-29 11:08:39.962525
776	driver1	-1.3913851	36.7634559	0	2025-04-29 11:08:44.62393
777	driver1	-1.3913851	36.7634559	0	2025-04-29 11:08:49.626241
778	driver1	-1.3913851	36.7634559	0	2025-04-29 11:08:54.622492
779	driver1	-1.3913851	36.7634559	0	2025-04-29 11:08:59.682276
780	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:04.682778
781	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:09.709182
782	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:14.731458
783	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:19.741485
784	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:24.750695
785	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:29.761731
786	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:34.771131
787	driver1	-4.05466	39.6636	0	2025-04-29 11:09:38.763764
788	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:39.698838
789	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:44.699108
790	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:49.699934
791	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:54.700379
792	driver1	-1.3913851	36.7634559	0	2025-04-29 11:09:59.700744
793	driver1	-1.3913851	36.7634559	0	2025-04-29 11:10:04.701291
794	driver1	-1.3913851	36.7634559	0	2025-04-29 11:10:09.76708
795	driver1	-4.05466	39.6636	0	2025-04-29 11:10:11.795561
796	driver1	-1.3913851	36.7634559	0	2025-04-29 11:10:14.787634
797	driver1	-1.3913851	36.7634559	0	2025-04-29 11:10:19.786936
798	driver1	-1.3913851	36.7634559	0	2025-04-29 11:10:24.786965
799	driver1	-4.05466	39.6636	0	2025-04-29 11:10:26.681515
800	driver1	-1.3913851	36.7634559	0	2025-04-29 11:10:29.789242
801	driver1	-1.3913851	36.7634559	0	2025-04-29 11:10:34.788838
802	driver1	-1.3913844	36.7634567	0	2025-04-29 11:10:44.23739
803	driver1	-1.3913844	36.7634567	0	2025-04-29 11:10:44.754303
804	driver1	-1.3913844	36.7634567	0	2025-04-29 11:10:49.756804
805	driver1	-1.3913844	36.7634567	0	2025-04-29 11:10:54.755238
806	driver1	-4.05466	39.6636	0	2025-04-29 11:10:57.854493
807	driver1	-1.3913844	36.7634567	0	2025-04-29 11:10:59.788608
808	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:04.78826
809	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:09.812568
810	driver1	-4.05466	39.6636	0	2025-04-29 11:11:13.065805
811	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:14.82395
812	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:19.883948
813	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:24.859513
814	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:29.863958
815	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:34.863544
816	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:39.799654
817	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:44.799914
818	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:49.800519
819	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:54.801203
820	driver1	-1.3913844	36.7634567	0	2025-04-29 11:11:59.801385
821	driver1	-1.3913844	36.7634567	0	2025-04-29 11:12:04.802394
822	driver1	-1.3913844	36.7634567	0	2025-04-29 11:12:09.803099
823	driver1	-1.3913844	36.7634567	0	2025-04-29 11:12:14.802668
824	driver1	-4.05466	39.6636	0	2025-04-29 11:12:19.454071
825	driver1	-1.3913844	36.7634567	0	2025-04-29 11:12:19.817559
826	driver1	-1.3913844	36.7634567	0	2025-04-29 11:12:24.815686
827	driver1	-1.3913844	36.7634567	0	2025-04-29 11:12:29.816559
828	driver1	-1.3913844	36.7634567	0	2025-04-29 11:12:34.818153
829	driver1	-1.3913844	36.7634567	0	2025-04-29 11:12:39.845351
830	driver1	-1.3913893	36.7634508	0	2025-04-29 11:12:40.121431
831	driver1	-1.3913893	36.7634508	0	2025-04-29 11:12:44.874413
832	driver1	-1.3913893	36.7634508	0	2025-04-29 11:12:49.875269
833	driver1	-4.05466	39.6636	0	2025-04-29 11:12:52.477184
834	driver1	-1.3913893	36.7634508	0	2025-04-29 11:12:54.875957
835	driver1	-1.3913893	36.7634508	0	2025-04-29 11:12:59.87624
836	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:04.877227
837	driver1	-4.05466	39.6636	0	2025-04-29 11:13:05.192045
838	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:09.876993
839	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:14.877745
840	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:19.962233
841	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:24.966737
842	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:29.982398
843	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:34.982962
844	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:39.922249
845	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:44.923256
846	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:49.924985
847	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:54.925353
848	driver1	-1.3913893	36.7634508	0	2025-04-29 11:13:59.924544
849	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:04.925511
850	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:09.925304
851	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:15.009282
852	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:20.010447
853	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:25.02607
854	driver1	-4.05466	39.6636	0	2025-04-29 11:14:29.149976
855	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:30.037729
856	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:35.038878
857	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:39.983064
858	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:44.988284
859	driver1	-4.05466	39.6636	0	2025-04-29 11:14:46.70697
860	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:49.994653
861	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:54.994429
862	driver1	-1.3913893	36.7634508	0	2025-04-29 11:14:59.994322
863	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:04.995152
864	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:10.056114
865	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:15.056962
866	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:20.060845
867	driver1	-4.05466	39.6636	0	2025-04-29 11:15:21.669329
868	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:25.05823
869	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:30.101892
870	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:35.1025
871	driver1	-4.05466	39.6636	0	2025-04-29 11:15:37.205672
872	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:40.043331
873	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:45.044046
874	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:50.04418
875	driver1	-4.05466	39.6636	0	2025-04-29 11:15:54.549191
876	driver1	-1.3913893	36.7634508	0	2025-04-29 11:15:55.069306
877	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:00.069825
878	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:05.070247
879	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:10.107546
880	driver1	-4.05466	39.6636	0	2025-04-29 11:16:11.883878
881	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:15.117677
882	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:20.117063
883	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:25.117465
884	driver1	-4.05466	39.6636	0	2025-04-29 11:16:25.688346
885	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:30.117982
886	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:35.118532
887	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:40.119987
888	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:40.137802
889	driver1	-4.05466	39.6636	0	2025-04-29 11:16:42.090555
890	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:45.138683
891	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:50.139521
892	driver1	-1.3913893	36.7634508	0	2025-04-29 11:16:55.139443
893	driver1	-4.05466	39.6636	0	2025-04-29 11:16:56.893186
894	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:00.139937
895	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:05.192571
896	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:10.192947
897	driver1	-4.05466	39.6636	0	2025-04-29 11:17:12.745341
898	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:15.193286
899	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:20.193498
900	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:25.19386
901	driver1	-4.05466	39.6636	0	2025-04-29 11:17:29.504658
902	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:30.193984
903	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:35.260165
904	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:40.238701
905	driver1	-4.05466	39.6636	0	2025-04-29 11:17:43.910253
906	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:45.271123
907	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:50.273582
908	driver1	-1.3913893	36.7634508	0	2025-04-29 11:17:55.276341
909	driver1	-4.05466	39.6636	0	2025-04-29 11:17:58.842916
910	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:00.311728
911	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:05.364841
912	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:10.365717
913	driver1	-4.05466	39.6636	0	2025-04-29 11:18:13.78487
914	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:15.365139
915	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:20.365414
916	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:25.366036
917	driver1	-4.05466	39.6636	0	2025-04-29 11:18:28.921066
918	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:30.410866
919	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:35.454065
920	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:40.287697
921	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:45.289263
922	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:50.306427
923	driver1	-4.05466	39.6636	0	2025-04-29 11:18:53.759528
924	driver1	-1.3913893	36.7634508	0	2025-04-29 11:18:55.331719
925	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:00.327774
926	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:05.358493
927	driver1	-4.05466	39.6636	0	2025-04-29 11:19:08.887259
928	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:10.380756
929	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:15.383082
930	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:20.383472
931	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:25.382259
932	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:30.382085
933	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:35.451436
934	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:40.375736
935	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:45.376451
936	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:50.388373
937	driver1	-4.05466	39.6636	0	2025-04-29 11:19:55.183218
938	driver1	-1.3913893	36.7634508	0	2025-04-29 11:19:55.425518
939	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:00.423075
940	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:05.441243
941	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:10.460823
942	driver1	-4.05466	39.6636	0	2025-04-29 11:20:10.864471
943	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:15.468243
944	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:20.459599
945	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:25.458925
946	driver1	-4.05466	39.6636	0	2025-04-29 11:20:26.090167
947	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:30.459386
948	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:35.52998
949	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:40.454141
950	driver1	-4.05466	39.6636	0	2025-04-29 11:20:40.7264
951	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:45.460448
952	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:50.46525
953	driver1	-1.3913893	36.7634508	0	2025-04-29 11:20:55.465295
954	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:00.466198
955	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:05.492263
956	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:10.508454
957	driver1	-4.05466	39.6636	0	2025-04-29 11:21:11.066853
958	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:15.510318
959	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:20.50987
960	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:25.510662
961	driver1	-4.05466	39.6636	0	2025-04-29 11:21:27.026765
962	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:30.510424
963	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:35.562052
964	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:40.524477
965	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:45.524542
966	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:50.525953
967	driver1	-1.3913893	36.7634508	0	2025-04-29 11:21:55.526397
968	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:00.525783
969	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:05.559654
970	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:10.559072
971	driver1	-4.05466	39.6636	0	2025-04-29 11:22:12.017508
972	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:15.559508
973	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:20.560315
974	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:25.561245
975	driver1	-4.05466	39.6636	0	2025-04-29 11:22:28.515529
976	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:30.561503
977	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:35.629796
978	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:40.559838
979	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:45.560285
980	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:50.560096
981	driver1	-1.3913893	36.7634508	0	2025-04-29 11:22:55.561759
982	driver1	-4.05466	39.6636	0	2025-04-29 11:22:59.852547
983	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:00.563723
984	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:05.592545
985	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:10.592948
986	driver1	-4.05466	39.6636	0	2025-04-29 11:23:14.273027
987	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:15.621016
988	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:20.636463
989	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:25.636438
990	driver1	-4.05466	39.6636	0	2025-04-29 11:23:29.113296
991	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:30.655374
992	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:35.668204
993	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:40.600107
994	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:45.599228
995	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:50.600101
996	driver1	-4.05466	39.6636	0	2025-04-29 11:23:55.221262
997	driver1	-1.3913893	36.7634508	0	2025-04-29 11:23:55.617078
998	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:00.617671
999	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:05.61714
1000	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:10.617992
1001	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:15.66901
1002	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:20.680888
1003	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:25.692541
1004	driver1	-4.05466	39.6636	0	2025-04-29 11:24:25.729032
1005	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:30.691707
1006	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:35.692074
1007	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:40.661567
1008	driver1	-4.05466	39.6636	0	2025-04-29 11:24:40.795466
1009	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:45.661875
1010	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:50.662126
1011	driver1	-1.3913893	36.7634508	0	2025-04-29 11:24:55.662553
1012	driver1	-4.05466	39.6636	0	2025-04-29 11:24:56.956494
1013	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:00.663613
1014	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:05.662853
1015	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:10.663826
1016	driver1	-4.05466	39.6636	0	2025-04-29 11:25:12.864753
1017	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:15.663812
1018	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:20.665544
1019	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:25.664419
1020	driver1	-4.05466	39.6636	0	2025-04-29 11:25:27.022275
1021	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:30.666582
1022	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:35.702847
1023	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:40.7208
1024	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:40.735603
1025	driver1	-4.05466	39.6636	0	2025-04-29 11:25:43.100318
1026	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:45.736019
1027	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:50.736415
1028	driver1	-1.3913893	36.7634508	0	2025-04-29 11:25:55.753923
1029	driver1	-4.05466	39.6636	0	2025-04-29 11:25:57.761144
1030	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:00.754639
1031	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:05.772889
1032	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:10.780359
1033	driver1	-4.05466	39.6636	0	2025-04-29 11:26:14.054955
1034	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:15.792083
1035	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:20.812134
1036	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:25.813139
1037	driver1	-4.05466	39.6636	0	2025-04-29 11:26:30.613692
1038	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:30.840558
1039	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:35.83971
1040	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:40.800861
1041	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:45.799384
1042	driver1	-4.05466	39.6636	0	2025-04-29 11:26:46.28566
1043	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:50.799014
1044	driver1	-1.3913893	36.7634508	0	2025-04-29 11:26:55.799186
1045	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:00.799584
1046	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:05.800308
1047	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:10.800553
1048	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:15.800861
1049	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:20.801036
1050	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:25.801619
1051	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:30.824273
1052	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:35.824326
1053	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:40.824669
1054	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:40.840038
1055	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:45.840672
1056	driver1	-4.05466	39.6636	0	2025-04-29 11:27:47.128099
1057	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:50.840709
1058	driver1	-1.3913893	36.7634508	0	2025-04-29 11:27:55.841115
1059	driver1	-4.05466	39.6636	0	2025-04-29 11:28:00.818357
1060	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:00.870613
1061	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:05.870993
1062	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:10.871555
1063	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:15.87184
1064	driver1	-4.05466	39.6636	0	2025-04-29 11:28:17.125014
1065	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:20.950438
1066	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:25.950328
1067	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:30.958055
1068	driver1	-4.05466	39.6636	0	2025-04-29 11:28:32.731991
1069	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:35.958441
1070	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:40.923468
1071	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:45.923635
1072	driver1	-4.05466	39.6636	0	2025-04-29 11:28:47.674992
1073	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:50.923669
1074	driver1	-4.05466	39.6636	0	2025-04-29 11:28:54.842803
1075	driver1	-1.3913893	36.7634508	0	2025-04-29 11:28:55.937433
1076	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:00.949284
1077	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:05.949625
1078	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:10.949988
1079	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:15.974844
1080	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:20.975157
1081	driver1	-4.05466	39.6636	0	2025-04-29 11:29:24.913418
1082	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:26.017169
1083	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:31.01681
1084	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:36.017708
1085	driver1	-4.05466	39.6636	0	2025-04-29 11:29:40.064525
1086	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:40.947844
1087	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:45.947788
1088	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:50.974948
1089	driver1	-1.3913893	36.7634508	0	2025-04-29 11:29:55.97431
1090	driver1	-4.05466	39.6636	0	2025-04-29 11:29:57.415612
1091	driver1	-1.3913893	36.7634508	0	2025-04-29 11:30:00.990256
1092	driver1	-1.3913893	36.7634508	0	2025-04-29 11:30:05.990264
1093	driver1	-1.3913893	36.7634508	0	2025-04-29 11:30:10.990768
1094	driver1	-1.3913893	36.7634508	0	2025-04-29 11:30:15.991069
1095	driver1	-1.3913893	36.7634508	0	2025-04-29 11:30:20.99205
1096	driver1	-1.3913893	36.7634508	0	2025-04-29 11:30:25.991634
1097	driver1	-1.3913893	36.7634508	0	2025-04-29 11:30:31.074496
1098	driver1	-1.3913893	36.7634508	0	2025-04-29 11:30:36.074193
1099	driver1	-1.3913839	36.7634539	0	2025-04-29 11:30:42.258648
1100	driver1	-1.3913839	36.7634539	0	2025-04-29 11:30:46.008121
1101	driver1	-1.3913839	36.7634539	0	2025-04-29 11:30:51.019494
1102	driver1	-1.3913839	36.7634539	0	2025-04-29 11:30:56.019805
1103	driver1	-4.05466	39.6636	0	2025-04-29 11:30:58.105501
1104	driver1	-1.3913839	36.7634539	0	2025-04-29 11:31:01.040673
1105	driver1	-1.3913839	36.7634539	0	2025-04-29 11:31:06.040976
1106	driver1	-1.3913839	36.7634539	0	2025-04-29 11:31:11.041597
1107	driver1	-4.05466	39.6636	0	2025-04-29 11:31:13.127588
1108	driver1	-1.3913839	36.7634539	0	2025-04-29 11:31:16.087013
1109	driver1	-1.3913839	36.7634539	0	2025-04-29 11:31:21.089263
1110	driver1	-1.3913839	36.7634539	0	2025-04-29 11:31:26.117237
1111	driver1	-1.3913839	36.7634539	0	2025-04-29 11:31:31.125373
1112	driver1	-1.3913839	36.7634539	0	2025-04-29 11:31:36.125854
1113	driver1	-1.3913816	36.7634586	0	2025-04-29 11:31:41.671022
1114	driver1	-4.05466	39.6636	0	2025-04-29 11:31:45.138241
1115	driver1	-1.3913816	36.7634586	0	2025-04-29 11:31:46.06018
1116	driver1	-1.3913816	36.7634586	0	2025-04-29 11:31:51.061795
1117	driver1	-1.3913816	36.7634586	0	2025-04-29 11:31:56.06113
1118	driver1	-4.05466	39.6636	0	2025-04-29 11:32:00.875821
1119	driver1	-1.3913816	36.7634586	0	2025-04-29 11:32:01.069277
1120	driver1	-1.3913816	36.7634586	0	2025-04-29 11:32:06.069781
1121	driver1	-1.3913816	36.7634586	0	2025-04-29 11:32:11.069947
1122	driver1	-1.3913816	36.7634586	0	2025-04-29 11:32:16.070822
1123	driver1	-1.3913816	36.7634586	0	2025-04-29 11:32:21.133134
1124	driver1	-1.3913816	36.7634586	0	2025-04-29 11:32:26.196468
1125	driver1	-4.05466	39.6636	0	2025-04-29 11:32:30.821584
1126	driver1	-1.3913816	36.7634586	0	2025-04-29 11:32:31.245939
1127	driver1	-1.3913816	36.7634586	0	2025-04-29 11:32:36.194695
1128	driver1	-1.3913816	36.7634552	0	2025-04-29 11:32:41.462996
1129	driver1	-4.05466	39.6636	0	2025-04-29 11:32:45.742371
1130	driver1	-1.3913816	36.7634552	0	2025-04-29 11:32:46.074454
1131	driver1	-1.3913816	36.7634552	0	2025-04-29 11:32:51.085976
1132	driver1	-1.3913816	36.7634552	0	2025-04-29 11:32:56.129751
1133	driver1	-1.3913816	36.7634552	0	2025-04-29 11:33:01.1475
1134	driver1	-4.05466	39.6636	0	2025-04-29 11:33:02.28595
1135	driver1	-1.3913816	36.7634552	0	2025-04-29 11:33:06.1476
1136	driver1	-1.3913816	36.7634552	0	2025-04-29 11:33:11.147787
1137	driver1	-1.3913816	36.7634552	0	2025-04-29 11:33:16.148381
1138	driver1	-4.05466	39.6636	0	2025-04-29 11:33:17.314534
1139	driver1	-1.3913816	36.7634552	0	2025-04-29 11:33:21.149543
1140	driver1	-1.3913816	36.7634552	0	2025-04-29 11:33:26.149158
1141	driver1	-1.3913816	36.7634552	0	2025-04-29 11:33:31.157485
1142	driver1	-4.05466	39.6636	0	2025-04-29 11:33:32.04473
1143	driver1	-1.3913816	36.7634552	0	2025-04-29 11:33:36.158259
1144	driver1	-1.3913808	36.7634542	0	2025-04-29 11:33:42.943539
1145	driver1	-1.3913808	36.7634542	0	2025-04-29 11:33:46.104399
1146	driver1	-4.05466	39.6636	0	2025-04-29 11:33:47.046079
1147	driver1	-1.3913808	36.7634542	0	2025-04-29 11:33:51.132305
1148	driver1	-4.05466	39.6636	0	2025-04-29 11:33:55.343566
1149	driver1	-1.3913808	36.7634542	0	2025-04-29 11:33:56.143849
1150	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:01.146793
1151	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:06.144639
1152	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:11.145352
1153	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:16.145987
1154	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:21.165732
1155	driver1	-4.05466	39.6636	0	2025-04-29 11:34:26.13491
1156	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:26.167461
1157	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:31.167725
1158	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:36.191668
1159	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:41.128617
1160	driver1	-4.05466	39.6636	0	2025-04-29 11:34:43.509102
1161	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:46.132179
1162	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:51.128925
1163	driver1	-1.3913808	36.7634542	0	2025-04-29 11:34:56.171375
1164	driver1	-4.05466	39.6636	0	2025-04-29 11:35:00.013988
1165	driver1	-1.3913808	36.7634542	0	2025-04-29 11:35:01.18165
1166	driver1	-1.3913808	36.7634542	0	2025-04-29 11:35:06.179294
1167	driver1	-1.3913808	36.7634542	0	2025-04-29 11:35:11.179754
1168	driver1	-1.3913808	36.7634542	0	2025-04-29 11:35:16.179931
1169	driver1	-4.05466	39.6636	0	2025-04-29 11:35:18.317462
1170	driver1	-1.3913808	36.7634542	0	2025-04-29 11:35:21.181017
1171	driver1	-1.3913808	36.7634542	0	2025-04-29 11:35:26.180792
1172	driver1	-1.3913808	36.7634542	0	2025-04-29 11:35:31.181234
1173	driver1	-1.3913808	36.7634542	0	2025-04-29 11:35:36.181336
1174	driver1	-1.3913847	36.7634579	0	2025-04-29 11:35:41.50931
1175	driver1	-1.3913847	36.7634579	0	2025-04-29 11:35:46.180841
1176	driver1	-4.05466	39.6636	0	2025-04-29 11:35:48.143339
1177	driver1	-1.3913847	36.7634579	0	2025-04-29 11:35:51.181987
1178	driver1	-1.3913847	36.7634579	0	2025-04-29 11:35:56.193674
1179	driver1	-1.3913847	36.7634579	0	2025-04-29 11:36:01.19277
1180	driver1	-4.05466	39.6636	0	2025-04-29 11:36:05.035159
1181	driver1	-1.3913847	36.7634579	0	2025-04-29 11:36:06.19292
1182	driver1	-1.3913847	36.7634579	0	2025-04-29 11:36:11.193772
1183	driver1	-1.3913847	36.7634579	0	2025-04-29 11:36:16.193908
1184	driver1	-1.3913847	36.7634579	0	2025-04-29 11:36:21.196077
1185	driver1	-1.3913847	36.7634579	0	2025-04-29 11:36:26.204543
1186	driver1	-1.3913847	36.7634579	0	2025-04-29 11:36:31.201443
1187	driver1	-4.05466	39.6636	0	2025-04-29 11:36:36.00219
1188	driver1	-1.3913847	36.7634579	0	2025-04-29 11:36:36.254234
1189	driver1	-1.3913808	36.7634535	0	2025-04-29 11:36:42.205785
1190	driver1	-1.3913808	36.7634535	0	2025-04-29 11:36:46.198034
1191	driver1	-1.3913808	36.7634535	0	2025-04-29 11:36:51.199136
1192	driver1	-4.05466	39.6636	0	2025-04-29 11:36:51.854297
1193	driver1	-1.3913808	36.7634535	0	2025-04-29 11:36:56.216531
1194	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:01.216658
1195	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:06.217369
1196	driver1	-4.05466	39.6636	0	2025-04-29 11:37:09.245821
1197	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:11.250935
1198	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:16.251333
1199	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:21.251982
1200	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:26.282443
1201	driver1	-4.05466	39.6636	0	2025-04-29 11:37:29.324412
1202	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:31.318156
1203	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:33.037341
1204	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:33.043075
1205	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:38.03801
1206	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:41.261055
1207	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:46.259839
1208	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:51.260823
1209	driver1	-1.3913808	36.7634535	0	2025-04-29 11:37:56.260391
1210	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:01.260794
1211	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:06.261098
1212	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:11.262003
1213	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:16.26401
1214	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:21.336251
1215	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:26.337102
1216	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:31.338945
1217	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:36.337824
1218	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:41.290978
1219	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:46.291623
1220	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:51.292805
1221	driver1	-1.3913808	36.7634535	0	2025-04-29 11:38:56.292821
1222	driver1	-1.3913808	36.7634535	0	2025-04-29 11:39:01.2932
1223	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:04.50999
1224	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:04.678108
1225	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:04.729405
1226	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:08.158309
1227	driver1	-4.05466	39.6636	0	2025-04-29 11:39:11.221592
1228	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:13.181227
1229	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:18.181848
1230	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:23.203091
1231	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:28.203401
1232	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:33.22844
1233	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:38.229116
1234	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:41.357201
1235	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:46.357466
1236	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:51.358168
1237	driver1	-1.3913829	36.7634585	0	2025-04-29 11:39:56.358729
1238	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:01.359155
1239	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:06.359482
1240	driver1	-4.05466	39.6636	0	2025-04-29 11:40:09.685399
1241	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:11.36034
1242	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:16.360543
1243	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:21.409834
1244	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:26.45043
1245	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:31.450774
1246	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:36.451075
1247	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:41.401825
1248	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:46.402266
1249	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:51.415015
1250	driver1	-1.3913829	36.7634585	0	2025-04-29 11:40:56.41563
1251	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:01.416038
1252	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:06.41666
1253	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:11.594383
1254	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:16.593707
1255	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:21.694405
1256	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:26.695358
1257	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:31.695902
1258	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:36.69632
1259	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:41.69713
1260	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:41.708636
1261	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:46.709402
1262	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:51.710466
1263	driver1	-1.3913829	36.7634585	0	2025-04-29 11:41:56.710991
1264	driver1	-1.3913829	36.7634585	0	2025-04-29 11:42:02.096986
1265	driver1	-1.3913829	36.7634585	0	2025-04-29 11:42:07.099203
1266	driver1	-1.3913829	36.7634585	0	2025-04-29 11:42:12.103535
1267	driver1	-1.3913829	36.7634585	0	2025-04-29 11:42:17.108828
1268	driver1	-4.05466	39.6636	0	2025-04-29 11:42:19.885526
1269	driver1	-1.3913829	36.7634585	0	2025-04-29 11:42:22.71939
1270	driver1	-1.3913829	36.7634585	0	2025-04-29 11:42:27.711942
1271	driver1	-1.3913829	36.7634585	0	2025-04-29 11:42:32.712852
1272	driver1	-1.3913829	36.7634585	0	2025-04-29 11:42:37.712838
1273	driver1	-1.3913824	36.7634575	0	2025-04-29 11:42:43.301001
1274	driver1	-1.3913824	36.7634575	0	2025-04-29 11:42:46.725463
1275	driver1	-1.3913824	36.7634575	0	2025-04-29 11:42:51.725856
1276	driver1	-1.3913824	36.7634575	0	2025-04-29 11:42:56.726353
1277	driver1	-1.3913824	36.7634575	0	2025-04-29 11:43:01.726559
1278	driver1	-1.3913824	36.7634575	0	2025-04-29 11:43:06.727304
1279	driver1	-4.05466	39.6636	0	2025-04-29 11:43:08.526086
1280	driver1	-1.3913824	36.7634575	0	2025-04-29 11:43:11.805971
1281	driver1	-1.3913824	36.7634575	0	2025-04-29 11:43:16.806702
1282	driver1	-1.3913824	36.7634575	0	2025-04-29 11:43:21.80701
1283	driver1	-1.3913824	36.7634575	0	2025-04-29 11:43:26.807494
1284	driver1	-1.3913824	36.7634575	0	2025-04-29 11:43:31.811125
1285	driver1	-1.3913824	36.7634575	0	2025-04-29 11:43:37.204727
1286	driver1	-4.05466	39.6636	0	2025-04-29 11:43:39.094988
1287	driver1	-1.3913824	36.7634575	0	2025-04-29 11:43:42.329393
1288	driver1	-1.3913825	36.7634576	0	2025-04-29 11:43:42.530891
1289	driver1	-1.3913825	36.7634576	0	2025-04-29 11:43:47.359556
1290	driver1	-1.3913825	36.7634576	0	2025-04-29 11:43:52.358706
1291	driver1	-4.05466	39.6636	0	2025-04-29 11:43:52.761043
1292	driver1	-1.3913825	36.7634576	0	2025-04-29 11:43:57.358871
1293	driver1	-1.3913825	36.7634576	0	2025-04-29 11:44:02.35999
1294	driver1	-1.3913825	36.7634576	0	2025-04-29 11:44:07.359518
1295	driver1	-1.3913825	36.7634576	0	2025-04-29 11:44:12.907672
1296	driver1	-1.3913825	36.7634576	0	2025-04-29 11:44:17.901736
1297	driver1	-1.3913825	36.7634576	0	2025-04-29 11:44:22.902265
1298	driver1	-4.05466	39.6636	0	2025-04-29 11:44:24.779649
1299	driver1	-1.3913825	36.7634576	0	2025-04-29 11:44:27.977542
1300	driver1	-1.3913825	36.7634576	0	2025-04-29 11:44:32.978053
1301	driver1	-1.3913825	36.7634576	0	2025-04-29 11:44:37.981246
1302	driver1	-4.05466	39.6636	0	2025-04-29 11:44:42.801896
1303	driver1	-1.3913838	36.7634554	0	2025-04-29 11:44:43.132738
1304	driver1	-1.3913838	36.7634554	0	2025-04-29 11:44:47.823369
1305	driver1	-1.3913838	36.7634554	0	2025-04-29 11:44:52.824134
1306	driver1	-1.3913838	36.7634554	0	2025-04-29 11:44:58.2891
1307	driver1	-1.3913838	36.7634554	0	2025-04-29 11:45:03.2892
1308	driver1	-1.3913838	36.7634554	0	2025-04-29 11:45:08.289974
1309	driver1	-1.3913838	36.7634554	0	2025-04-29 11:45:13.298822
1310	driver1	-4.05466	39.6636	0	2025-04-29 11:45:15.660437
1311	driver1	-1.3913838	36.7634554	0	2025-04-29 11:45:18.299425
1312	driver1	-1.3913838	36.7634554	0	2025-04-29 11:45:23.299885
1313	driver1	-1.3913838	36.7634554	0	2025-04-29 11:45:28.300356
1314	driver1	-4.05466	39.6636	0	2025-04-29 11:45:30.644449
1315	driver1	-1.3913838	36.7634554	0	2025-04-29 11:45:33.300752
1316	driver1	-1.3913838	36.7634554	0	2025-04-29 11:45:38.547788
1317	driver1	-1.3913886	36.7634525	0	2025-04-29 11:45:43.072934
1318	driver1	-4.05466	39.6636	0	2025-04-29 11:45:45.784649
1319	driver1	-1.3913886	36.7634525	0	2025-04-29 11:45:47.843818
1320	driver1	-1.3913886	36.7634525	0	2025-04-29 11:45:52.844742
1321	driver1	-1.3913886	36.7634525	0	2025-04-29 11:45:58.421077
1322	driver1	-4.05466	39.6636	0	2025-04-29 11:46:01.765884
1323	driver1	-1.3913886	36.7634525	0	2025-04-29 11:46:03.450869
1324	driver1	-1.3913886	36.7634525	0	2025-04-29 11:46:08.452463
1325	driver1	-1.3913886	36.7634525	0	2025-04-29 11:46:13.520773
1326	driver1	-1.3913886	36.7634525	0	2025-04-29 11:46:18.520159
1327	driver1	-1.3913886	36.7634525	0	2025-04-29 11:46:23.52047
1328	driver1	-1.3913886	36.7634525	0	2025-04-29 11:46:28.521101
1329	driver1	-1.3913886	36.7634525	0	2025-04-29 11:46:33.521973
1330	driver1	-4.05466	39.6636	0	2025-04-29 11:46:37.209456
1331	driver1	-1.3913886	36.7634525	0	2025-04-29 11:46:38.586409
1332	driver1	-1.3913886	36.7634525	0	2025-04-29 11:46:43.781102
1333	driver1	-1.3913827	36.7634589	0	2025-04-29 11:46:43.988378
1334	driver1	-1.3913827	36.7634589	0	2025-04-29 11:46:49.279535
1335	driver1	-4.05466	39.6636	0	2025-04-29 11:46:52.317764
1336	driver1	-1.3913827	36.7634589	0	2025-04-29 11:46:54.279677
1337	driver1	-1.3913827	36.7634589	0	2025-04-29 11:46:59.280396
1338	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:04.706483
1339	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:09.695223
1340	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:14.695567
1341	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:19.86881
1342	driver1	-4.05466	39.6636	0	2025-04-29 11:47:20.693696
1343	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:24.869469
1344	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:29.874466
1345	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:34.993462
1346	driver1	-4.05466	39.6636	0	2025-04-29 11:47:38.065005
1347	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:39.993709
1348	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:43.812454
1349	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:48.812893
1350	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:53.813733
1351	driver1	-4.05466	39.6636	0	2025-04-29 11:47:54.70697
1352	driver1	-1.3913827	36.7634589	0	2025-04-29 11:47:58.814291
1353	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:03.815039
1354	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:09.042272
1355	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:14.407443
1356	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:19.408009
1357	driver1	-4.05466	39.6636	0	2025-04-29 11:48:23.630497
1358	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:24.410304
1359	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:29.41065
1360	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:34.41089
1361	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:39.412198
1362	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:44.412855
1363	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:44.429686
1364	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:49.430322
1365	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:54.430844
1366	driver1	-4.05466	39.6636	0	2025-04-29 11:48:54.797
1367	driver1	-1.3913827	36.7634589	0	2025-04-29 11:48:59.63263
1368	driver1	-1.3913827	36.7634589	0	2025-04-29 11:49:04.63316
1369	driver1	-1.3913827	36.7634589	0	2025-04-29 11:49:09.878026
1370	driver1	-1.3913827	36.7634589	0	2025-04-29 11:49:14.884718
1371	driver1	-4.05466	39.6636	0	2025-04-29 11:49:15.90569
1372	driver1	-1.3913827	36.7634589	0	2025-04-29 11:49:19.884574
1373	driver1	-1.3913827	36.7634589	0	2025-04-29 11:49:24.884982
1374	driver1	-1.3913827	36.7634589	0	2025-04-29 11:49:29.885504
1375	driver1	-1.3913827	36.7634589	0	2025-04-29 11:49:34.994167
1376	driver1	-1.3913827	36.7634589	0	2025-04-29 11:49:39.993466
1377	driver1	-1.3913827	36.7634589	0	2025-04-29 11:49:44.994188
1378	driver1	-1.3913927	36.7634517	0	2025-04-29 11:49:46.084902
1379	driver1	-4.05466	39.6636	0	2025-04-29 11:49:48.757807
1380	driver1	-1.3913927	36.7634517	0	2025-04-29 11:49:50.018479
1381	driver1	-1.3913927	36.7634517	0	2025-04-29 11:49:55.019267
1382	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:00.019853
1383	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:05.020622
1384	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:10.269258
1385	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:15.274041
1386	driver1	-4.05466	39.6636	0	2025-04-29 11:50:19.773782
1387	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:20.27767
1388	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:25.278226
1389	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:30.476968
1390	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:35.477366
1391	driver1	-4.05466	39.6636	0	2025-04-29 11:50:35.877096
1392	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:40.477979
1393	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:45.036845
1394	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:50.037401
1395	driver1	-4.05466	39.6636	0	2025-04-29 11:50:51.645726
1396	driver1	-1.3913927	36.7634517	0	2025-04-29 11:50:55.133358
1397	driver1	-1.3913927	36.7634517	0	2025-04-29 11:51:00.133672
1398	driver1	-1.3913927	36.7634517	0	2025-04-29 11:51:05.134469
1399	driver1	-4.05466	39.6636	0	2025-04-29 11:51:06.772577
1400	driver1	-1.3913927	36.7634517	0	2025-04-29 11:51:10.277109
1401	driver1	-1.3913927	36.7634517	0	2025-04-29 11:51:15.314729
1402	driver1	-1.3913927	36.7634517	0	2025-04-29 11:51:20.753588
1403	driver1	-4.05466	39.6636	0	2025-04-29 11:51:23.115686
1404	driver1	-1.3913927	36.7634517	0	2025-04-29 11:51:25.75244
1405	driver1	-1.3913927	36.7634517	0	2025-04-29 11:51:30.752857
1406	driver1	-1.3913927	36.7634517	0	2025-04-29 11:51:35.753361
1407	driver1	-4.05466	39.6636	0	2025-04-29 11:51:38.733696
1408	driver1	-1.3913927	36.7634517	0	2025-04-29 11:51:40.753855
1409	driver1	-1.3913811	36.7634574	0	2025-04-29 11:51:45.427422
1410	driver1	-1.3913811	36.7634574	0	2025-04-29 11:51:50.263414
1411	driver1	-4.05466	39.6636	0	2025-04-29 11:51:53.557117
1412	driver1	-1.3913811	36.7634574	0	2025-04-29 11:51:55.263913
1413	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:00.264462
1414	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:05.297481
1415	driver1	-4.05466	39.6636	0	2025-04-29 11:52:07.709545
1416	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:10.77189
1417	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:15.771396
1418	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:21.312371
1419	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:26.312872
1420	driver1	-4.05466	39.6636	0	2025-04-29 11:52:26.4515
1421	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:31.313509
1422	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:36.313971
1423	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:41.314509
1424	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:45.543894
1425	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:50.544597
1426	driver1	-4.05466	39.6636	0	2025-04-29 11:52:53.696404
1427	driver1	-1.3913811	36.7634574	0	2025-04-29 11:52:55.544768
1428	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:00.545363
1429	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:05.545885
1430	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:10.967046
1431	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:15.967474
1432	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:20.967882
1433	driver1	-4.05466	39.6636	0	2025-04-29 11:53:24.134519
1434	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:25.968484
1435	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:30.968901
1436	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:36.230589
1437	driver1	-4.05466	39.6636	0	2025-04-29 11:53:39.774275
1438	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:41.231256
1439	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:45.715155
1440	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:50.720468
1441	driver1	-4.05466	39.6636	0	2025-04-29 11:53:54.855559
1442	driver1	-1.3913811	36.7634574	0	2025-04-29 11:53:55.932549
1443	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:00.9271
1444	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:05.92755
1445	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:10.92826
1446	driver1	-4.05466	39.6636	0	2025-04-29 11:54:11.49566
1447	driver1	-4.05466	39.6636	0	2025-04-29 11:54:12.709717
1448	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:15.934245
1449	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:21.407442
1450	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:26.408059
1451	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:31.408573
1452	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:36.409423
1453	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:41.41008
1454	driver1	-4.05466	39.6636	0	2025-04-29 11:54:42.676687
1455	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:46.199699
1456	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:51.199902
1457	driver1	-1.3913811	36.7634574	0	2025-04-29 11:54:56.200233
1458	driver1	-4.05466	39.6636	0	2025-04-29 11:54:57.620722
1459	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:01.240957
1460	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:06.324685
1461	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:11.324706
1462	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:16.331758
1463	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:21.332236
1464	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:26.332926
1465	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:31.335275
1466	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:36.338415
1467	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:41.337029
1468	driver1	-4.05466	39.6636	0	2025-04-29 11:55:44.066397
1469	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:46.335151
1470	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:46.364509
1471	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:51.365705
1472	driver1	-1.3913811	36.7634574	0	2025-04-29 11:55:56.364965
1473	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:01.367241
1474	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:06.366396
1475	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:11.365904
1476	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:16.375096
1477	driver1	-4.05466	39.6636	0	2025-04-29 11:56:16.975346
1478	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:21.53134
1479	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:26.531761
1480	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:31.581722
1481	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:36.58281
1482	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:41.590908
1483	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:46.586876
1484	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:46.605559
1485	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:51.606251
1486	driver1	-1.3913811	36.7634574	0	2025-04-29 11:56:56.767225
1487	driver1	-4.05466	39.6636	0	2025-04-29 11:57:01.625972
1488	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:01.792486
1489	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:06.790029
1490	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:11.79046
1491	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:16.801245
1492	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:21.805275
1493	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:26.800617
1494	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:31.80279
1495	driver1	-4.05466	39.6636	0	2025-04-29 11:57:32.827901
1496	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:36.802088
1497	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:42.375422
1498	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:46.625921
1499	driver1	-4.05466	39.6636	0	2025-04-29 11:57:49.154276
1500	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:51.628742
1501	driver1	-1.3913811	36.7634574	0	2025-04-29 11:57:56.626891
1502	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:01.629281
1503	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:06.628276
1504	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:11.628714
1505	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:16.808543
1506	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:21.800357
1507	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:26.800925
1508	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:31.801435
1509	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:37.185766
1510	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:42.694778
1511	driver1	-4.05466	39.6636	0	2025-04-29 11:58:43.74668
1512	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:46.829464
1513	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:51.830102
1514	driver1	-1.3913811	36.7634574	0	2025-04-29 11:58:56.830355
1515	driver1	-4.05466	39.6636	0	2025-04-29 11:58:58.0489
1516	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:02.27568
1517	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:07.696989
1518	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:12.723881
1519	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:17.705546
1520	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:22.703969
1521	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:27.705078
1522	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:32.705518
1523	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:38.22975
1524	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:43.229863
1525	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:47.60944
1526	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:52.900647
1527	driver1	-4.05466	39.6636	0	2025-04-29 11:59:53.762433
1528	driver1	-1.3913811	36.7634574	0	2025-04-29 11:59:57.901267
1529	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:02.902047
1530	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:07.902361
1531	driver1	-4.05466	39.6636	0	2025-04-29 12:00:09.691878
1532	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:12.917557
1533	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:17.917367
1534	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:22.919218
1535	driver1	-4.05466	39.6636	0	2025-04-29 12:00:26.45609
1536	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:27.923648
1537	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:32.936489
1538	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:37.9368
1539	driver1	-4.05466	39.6636	0	2025-04-29 12:00:40.735971
1540	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:42.942625
1541	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:47.938731
1542	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:47.955742
1543	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:53.429983
1544	driver1	-1.3913811	36.7634574	0	2025-04-29 12:00:58.430384
1545	driver1	-4.05466	39.6636	0	2025-04-29 12:00:58.765131
1546	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:03.549644
1547	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:08.950268
1548	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:13.950821
1549	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:18.952075
1550	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:23.951803
1551	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:28.952238
1552	driver1	-4.05466	39.6636	0	2025-04-29 12:01:29.222932
1553	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:33.952904
1554	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:38.958602
1555	driver1	-4.05466	39.6636	0	2025-04-29 12:01:43.956292
1556	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:43.960672
1557	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:48.959565
1558	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:48.981125
1559	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:53.978282
1560	driver1	-4.05466	39.6636	0	2025-04-29 12:01:58.851095
1561	driver1	-1.3913811	36.7634574	0	2025-04-29 12:01:59.034752
1562	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:04.035392
1563	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:09.478882
1564	driver1	-4.05466	39.6636	0	2025-04-29 12:02:14.125247
1565	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:14.505421
1566	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:19.862976
1567	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:24.863486
1568	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:29.863836
1569	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:34.864507
1570	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:39.864958
1571	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:44.865692
1572	driver1	-1.3913811	36.7634574	0	2025-04-29 12:02:49.866099
1573	driver1	-1.3913783	36.7634538	0	2025-04-29 12:02:50.838269
1574	driver1	-1.3913783	36.7634538	0	2025-04-29 12:02:55.367095
1575	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:00.982734
1576	driver1	-4.05466	39.6636	0	2025-04-29 12:03:02.950487
1577	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:05.983115
1578	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:10.983739
1579	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:15.984031
1580	driver1	-4.05466	39.6636	0	2025-04-29 12:03:19.461527
1581	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:21.046857
1582	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:26.040066
1583	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:31.040679
1584	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:36.041023
1585	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:41.042169
1586	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:46.042394
1587	driver1	-4.05466	39.6636	0	2025-04-29 12:03:48.843564
1588	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:49.937464
1589	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:54.936648
1590	driver1	-1.3913783	36.7634538	0	2025-04-29 12:03:59.937282
1591	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:05.265494
1592	driver1	-4.05466	39.6636	0	2025-04-29 12:04:07.639093
1593	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:10.265669
1594	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:15.271625
1595	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:20.272249
1596	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:25.272589
1597	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:30.273183
1598	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:35.273702
1599	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:40.273904
1600	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:45.2746
1601	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:50.27535
1602	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:50.293289
1603	driver1	-4.05466	39.6636	0	2025-04-29 12:04:54.302349
1604	driver1	-1.3913783	36.7634538	0	2025-04-29 12:04:55.378272
1605	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:00.371759
1606	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:05.419003
1607	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:10.768774
1608	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:15.769585
1609	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:20.770082
1610	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:26.170848
1611	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:31.170959
1612	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:36.171681
1613	driver1	-4.05466	39.6636	0	2025-04-29 12:05:40.640418
1614	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:41.220683
1615	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:46.221116
1616	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:51.22188
1617	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:51.238869
1618	driver1	-4.05466	39.6636	0	2025-04-29 12:05:56.208689
1619	driver1	-1.3913783	36.7634538	0	2025-04-29 12:05:56.239154
1620	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:01.418445
1621	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:06.418526
1622	driver1	-4.05466	39.6636	0	2025-04-29 12:06:10.80286
1623	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:11.421446
1624	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:16.422698
1625	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:21.42415
1626	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:26.423651
1627	driver1	-4.05466	39.6636	0	2025-04-29 12:06:28.637036
1628	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:31.429134
1629	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:36.430078
1630	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:41.431137
1631	driver1	-4.05466	39.6636	0	2025-04-29 12:06:43.626125
1632	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:46.431245
1633	driver1	-1.3913783	36.7634538	0	2025-04-29 12:06:51.436433
1634	driver1	-1.3913802	36.7634573	0	2025-04-29 12:06:51.840523
1635	driver1	-1.3913802	36.7634573	0	2025-04-29 12:06:56.455622
1636	driver1	-4.05466	39.6636	0	2025-04-29 12:06:58.637572
1637	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:01.680751
1638	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:06.691945
1639	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:11.690892
1640	driver1	-4.05466	39.6636	0	2025-04-29 12:07:12.803353
1641	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:16.691335
1642	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:22.235791
1643	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:27.236194
1644	driver1	-4.05466	39.6636	0	2025-04-29 12:07:28.639528
1645	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:32.236912
1646	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:37.237532
1647	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:42.238042
1648	driver1	-4.05466	39.6636	0	2025-04-29 12:07:43.832621
1649	driver1	-1.3913802	36.7634573	0	2025-04-29 12:07:47.238512
1650	driver1	-1.3913816	36.763458	0	2025-04-29 12:07:51.739143
1651	driver1	-1.3913816	36.763458	0	2025-04-29 12:07:56.563009
1652	driver1	-4.05466	39.6636	0	2025-04-29 12:07:57.876496
1653	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:01.616132
1654	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:06.616744
1655	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:11.617148
1656	driver1	-4.05466	39.6636	0	2025-04-29 12:08:12.619095
1657	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:16.617719
1658	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:21.618137
1659	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:27.197657
1660	driver1	-4.05466	39.6636	0	2025-04-29 12:08:27.665879
1661	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:32.198291
1662	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:37.717851
1663	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:42.718097
1664	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:47.71887
1665	driver1	-1.3913816	36.763458	0	2025-04-29 12:08:52.719867
1666	driver1	-1.3913796	36.7634535	0	2025-04-29 12:08:52.906933
1667	driver1	-1.3913796	36.7634535	0	2025-04-29 12:08:57.73725
1668	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:02.738289
1669	driver1	-4.05466	39.6636	0	2025-04-29 12:09:06.615243
1670	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:07.744968
1671	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:12.744331
1672	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:18.008486
1673	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:23.002524
1674	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:28.00206
1675	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:33.002784
1676	driver1	-4.05466	39.6636	0	2025-04-29 12:09:36.925043
1677	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:38.01658
1678	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:43.052239
1679	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:48.314859
1680	driver1	-4.05466	39.6636	0	2025-04-29 12:09:52.736757
1681	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:52.764401
1682	driver1	-1.3913796	36.7634535	0	2025-04-29 12:09:58.321348
1683	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:03.791395
1684	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:08.791738
1685	driver1	-4.05466	39.6636	0	2025-04-29 12:10:09.047293
1686	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:13.792071
1687	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:18.798845
1688	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:23.798745
1689	driver1	-4.05466	39.6636	0	2025-04-29 12:10:23.903739
1690	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:29.32608
1691	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:34.435136
1692	driver1	-4.05466	39.6636	0	2025-04-29 12:10:38.95727
1693	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:39.442497
1694	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:44.443014
1695	driver1	-1.3913796	36.7634535	0	2025-04-29 12:10:49.910594
1696	driver1	-1.3913876	36.7634546	0	2025-04-29 12:10:53.595571
1697	driver1	-4.05466	39.6636	0	2025-04-29 12:10:53.825076
1698	driver1	-1.3913876	36.7634546	0	2025-04-29 12:10:58.440017
1699	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:03.453314
1700	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:08.454129
1701	driver1	-4.05466	39.6636	0	2025-04-29 12:11:08.602696
1702	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:13.454642
1703	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:18.804169
1704	driver1	-4.05466	39.6636	0	2025-04-29 12:11:23.646631
1705	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:23.817184
1706	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:28.817341
1707	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:33.817714
1708	driver1	-4.05466	39.6636	0	2025-04-29 12:11:38.604582
1709	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:38.820221
1710	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:44.441017
1711	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:49.441867
1712	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:53.686263
1713	driver1	-1.3913876	36.7634546	0	2025-04-29 12:11:58.686384
1714	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:03.687174
1715	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:09.293281
1716	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:14.293853
1717	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:19.300956
1718	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:24.30052
1719	driver1	-4.05466	39.6636	0	2025-04-29 12:12:24.87819
1720	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:29.300976
1721	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:34.306747
1722	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:39.307198
1723	driver1	-4.05466	39.6636	0	2025-04-29 12:12:41.117351
1724	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:44.640633
1725	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:49.642563
1726	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:54.183941
1727	driver1	-1.3913876	36.7634546	0	2025-04-29 12:12:59.184397
1728	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:04.450284
1729	driver1	-4.05466	39.6636	0	2025-04-29 12:13:08.886613
1730	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:09.466994
1731	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:14.890253
1732	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:19.897252
1733	driver1	-4.05466	39.6636	0	2025-04-29 12:13:23.610155
1734	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:24.906732
1735	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:29.897498
1736	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:34.898181
1737	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:39.898799
1738	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:44.899543
1739	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:49.899725
1740	driver1	-4.05466	39.6636	0	2025-04-29 12:13:54.385373
1741	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:54.429056
1742	driver1	-1.3913876	36.7634546	0	2025-04-29 12:13:59.429315
1743	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:04.430241
1744	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:09.43112
1745	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:14.431717
1746	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:19.902613
1747	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:24.897659
1748	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:29.897752
1749	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:34.898575
1750	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:40.510677
1751	driver1	-4.05466	39.6636	0	2025-04-29 12:14:42.599626
1752	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:46.106488
1753	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:51.107173
1754	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:54.626578
1755	driver1	-4.05466	39.6636	0	2025-04-29 12:14:59.616658
1756	driver1	-1.3913876	36.7634546	0	2025-04-29 12:14:59.627279
1757	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:04.627808
1758	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:09.628171
1759	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:14.628777
1760	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:19.908469
1761	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:24.903304
1762	driver1	-4.05466	39.6636	0	2025-04-29 12:15:28.549409
1763	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:29.927796
1764	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:34.92802
1765	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:39.928565
1766	driver1	-4.05466	39.6636	0	2025-04-29 12:15:42.604856
1767	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:44.928883
1768	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:49.92954
1769	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:54.930374
1770	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:54.952066
1771	driver1	-1.3913876	36.7634546	0	2025-04-29 12:15:59.949713
1772	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:04.950722
1773	driver1	-4.05466	39.6636	0	2025-04-29 12:16:09.57173
1774	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:09.951716
1775	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:14.953169
1776	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:19.959097
1777	driver1	-4.05466	39.6636	0	2025-04-29 12:16:23.635238
1778	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:25.01411
1779	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:30.014935
1780	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:35.01533
1781	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:40.019349
1782	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:45.019697
1783	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:56.389429
1784	driver1	-1.3913876	36.7634546	0	2025-04-29 12:16:56.503026
1785	driver1	-4.05466	39.6636	0	2025-04-29 12:16:56.516058
1786	driver1	-4.05466	39.6636	0	2025-04-29 12:16:56.533848
1787	driver1	-1.3913821	36.7634603	0	2025-04-29 12:16:59.258928
1788	driver1	-4.05466	39.6636	0	2025-04-29 12:16:59.729248
1789	driver1	-1.3913811	36.7634597	0	2025-04-29 12:16:59.772327
1790	driver1	-1.3913811	36.7634597	0	2025-04-29 12:16:59.817859
1791	driver1	-1.3913811	36.7634597	0	2025-04-29 12:16:59.842548
1792	driver1	-1.3913811	36.7634597	0	2025-04-29 12:16:59.87504
1793	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:01.290079
1794	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:06.290176
1795	driver1	-4.05466	39.6636	0	2025-04-29 12:17:07.138874
1796	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:07.42024
1797	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:12.420729
1798	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:17.428781
1799	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:22.892197
1800	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:27.892705
1801	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:32.968273
1802	driver1	-4.05466	39.6636	0	2025-04-29 12:17:37.712789
1803	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:37.992035
1804	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:42.992553
1805	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:48.429387
1806	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:53.429519
1807	driver1	-4.05466	39.6636	0	2025-04-29 12:17:53.830732
1808	driver1	-1.3913811	36.7634597	0	2025-04-29 12:17:55.231585
1809	driver1	-1.3913811	36.7634597	0	2025-04-29 12:18:00.231727
1810	driver1	-1.3913811	36.7634597	0	2025-04-29 12:18:05.232039
1811	driver1	-1.3913811	36.7634597	0	2025-04-29 12:18:07.277969
1812	driver1	-1.3913811	36.7634597	0	2025-04-29 12:18:07.286566
1813	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:11.248022
1814	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:11.724478
1815	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:12.06987
1816	driver1	-4.05466	39.6636	0	2025-04-29 12:18:12.074674
1817	driver1	-4.05466	39.6636	0	2025-04-29 12:18:12.859131
1818	driver1	-4.05466	39.6636	0	2025-04-29 12:18:15.065291
1819	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:16.75843
1820	driver1	-4.05466	39.6636	0	2025-04-29 12:18:21.509906
1821	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:21.779348
1822	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:27.057567
1823	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:32.057236
1824	driver1	-4.05466	39.6636	0	2025-04-29 12:18:35.949881
1825	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:37.065566
1826	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:42.064365
1827	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:47.064824
1828	driver1	-1.3913778	36.7634575	0	2025-04-29 12:18:52.065444
1829	driver1	-1.3913842	36.7634602	0	2025-04-29 12:18:55.929061
1830	driver1	-1.3913842	36.7634602	0	2025-04-29 12:19:00.603921
1831	driver1	-4.05466	39.6636	0	2025-04-29 12:19:04.77947
1832	driver1	-1.3913842	36.7634602	0	2025-04-29 12:19:05.854147
1833	driver1	-1.3913842	36.7634602	0	2025-04-29 12:19:06.245714
1834	driver1	-1.3913842	36.7634602	0	2025-04-29 12:19:06.257989
1835	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:10.212066
1836	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:10.704196
1837	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:11.2376
1838	driver1	-4.05466	39.6636	0	2025-04-29 12:19:11.945393
1839	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:16.238543
1840	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:21.245883
1841	driver1	-4.05466	39.6636	0	2025-04-29 12:19:23.008679
1842	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:26.505081
1843	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:31.815786
1844	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:36.816232
1845	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:42.025408
1846	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:47.025871
1847	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:52.026327
1848	driver1	-1.3913804	36.7634558	0	2025-04-29 12:19:57.02687
1849	driver1	-1.3913808	36.763451	0	2025-04-29 12:19:57.374353
1850	driver1	-4.05466	39.6636	0	2025-04-29 12:19:59.194736
1851	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:02.046264
1852	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:07.046848
1853	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:12.266587
1854	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:17.267014
1855	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:22.267435
1856	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:27.403569
1857	driver1	-4.05466	39.6636	0	2025-04-29 12:20:29.754517
1858	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:32.460699
1859	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:37.46193
1860	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:43.050293
1861	driver1	-4.05466	39.6636	0	2025-04-29 12:20:45.307654
1862	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:48.050909
1863	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:53.051222
1864	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:58.056714
1865	driver1	-1.3913808	36.763451	0	2025-04-29 12:20:58.073902
1866	driver1	-4.05466	39.6636	0	2025-04-29 12:21:00.123814
1867	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:03.074405
1868	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:08.074621
1869	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:13.238474
1870	driver1	-4.05466	39.6636	0	2025-04-29 12:21:14.533838
1871	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:18.238707
1872	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:23.245701
1873	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:28.245719
1874	driver1	-4.05466	39.6636	0	2025-04-29 12:21:28.74469
1875	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:33.731906
1876	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:38.732309
1877	driver1	-4.05466	39.6636	0	2025-04-29 12:21:43.705129
1878	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:43.735786
1879	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:49.094696
1880	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:54.09507
1881	driver1	-1.3913808	36.763451	0	2025-04-29 12:21:58.092245
1882	driver1	-4.05466	39.6636	0	2025-04-29 12:21:58.64278
1883	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:03.092365
1884	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:08.092806
1885	driver1	-4.05466	39.6636	0	2025-04-29 12:22:12.630362
1886	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:13.108798
1887	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:18.101425
1888	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:23.252045
1889	driver1	-4.05466	39.6636	0	2025-04-29 12:22:27.622547
1890	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:28.292995
1891	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:33.625596
1892	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:38.626023
1893	driver1	-4.05466	39.6636	0	2025-04-29 12:22:42.617846
1894	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:43.711062
1895	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:48.704967
1896	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:53.953666
1897	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:58.954496
1898	driver1	-1.3913808	36.763451	0	2025-04-29 12:22:59.025037
1899	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:03.979084
1900	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:08.979319
1901	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:13.980018
1902	driver1	-4.05466	39.6636	0	2025-04-29 12:23:14.654237
1903	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:18.980754
1904	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:23.981103
1905	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:29.251935
1906	driver1	-4.05466	39.6636	0	2025-04-29 12:23:29.619316
1907	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:34.252471
1908	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:39.25292
1909	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:44.253734
1910	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:49.254291
1911	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:54.55128
1912	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:59.551795
1913	driver1	-1.3913808	36.763451	0	2025-04-29 12:23:59.572878
1914	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:04.568753
1915	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:09.569219
1916	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:14.56977
1917	driver1	-4.05466	39.6636	0	2025-04-29 12:24:14.837302
1918	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:19.570116
1919	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:24.740096
1920	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:29.740154
1921	driver1	-4.05466	39.6636	0	2025-04-29 12:24:32.034556
1922	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:34.740626
1923	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:39.740965
1924	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:44.745155
1925	driver1	-4.05466	39.6636	0	2025-04-29 12:24:44.830225
1926	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:49.745641
1927	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:54.747316
1928	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:59.749948
1929	driver1	-1.3913808	36.763451	0	2025-04-29 12:24:59.823996
1930	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:04.775741
1931	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:09.776311
1932	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:14.776553
1933	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:19.77711
1934	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:24.782955
1935	driver1	-4.05466	39.6636	0	2025-04-29 12:25:28.649249
1936	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:29.789766
1937	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:34.789542
1938	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:39.79112
1939	driver1	-4.05466	39.6636	0	2025-04-29 12:25:43.663941
1940	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:44.798647
1941	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:49.798348
1942	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:54.799328
1943	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:59.799628
1944	driver1	-1.3913808	36.763451	0	2025-04-29 12:25:59.821756
1945	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:04.819679
1946	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:09.82028
1947	driver1	-4.05466	39.6636	0	2025-04-29 12:26:14.590714
1948	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:14.865665
1949	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:19.866036
1950	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:24.872279
1951	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:29.871814
1952	driver1	-4.05466	39.6636	0	2025-04-29 12:26:29.959168
1953	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:34.872415
1954	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:39.944886
1955	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:44.945285
1956	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:49.945885
1957	driver1	-1.3913808	36.763451	0	2025-04-29 12:26:55.029311
1958	driver1	-4.05466	39.6636	0	2025-04-29 12:26:59.881005
1959	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:00.400187
1960	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:04.837895
1961	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:10.434793
1962	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:15.435834
1963	driver1	-4.05466	39.6636	0	2025-04-29 12:27:15.98434
1964	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:20.436651
1965	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:25.717529
1966	driver1	-4.05466	39.6636	0	2025-04-29 12:27:29.592691
1967	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:30.727542
1968	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:35.72533
1969	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:40.725856
1970	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:45.731072
1971	driver1	-4.05466	39.6636	0	2025-04-29 12:27:45.821243
1972	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:50.731703
1973	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:55.732264
1974	driver1	-1.3913863	36.7634565	0	2025-04-29 12:27:59.958094
1975	driver1	-4.05466	39.6636	0	2025-04-29 12:28:00.990737
1976	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:04.958521
1977	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:09.959148
1978	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:14.960002
1979	driver1	-4.05466	39.6636	0	2025-04-29 12:28:15.664759
1980	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:19.960774
1981	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:25.278197
1982	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:30.272367
1983	driver1	-4.05466	39.6636	0	2025-04-29 12:28:31.796072
1984	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:35.306033
1985	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:40.306546
1986	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:45.306943
1987	driver1	-4.05466	39.6636	0	2025-04-29 12:28:48.802027
1988	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:50.379545
1989	driver1	-1.3913863	36.7634565	0	2025-04-29 12:28:55.380229
1990	driver1	-1.3913863	36.7634565	0	2025-04-29 12:29:00.38062
1991	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:00.748373
1992	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:05.404634
1993	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:10.532006
1994	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:15.531822
1995	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:20.642177
1996	driver1	-4.05466	39.6636	0	2025-04-29 12:29:22.420882
1997	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:26.001761
1998	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:31.397849
1999	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:36.39853
2000	driver1	-4.05466	39.6636	0	2025-04-29 12:29:36.681814
2001	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:41.398723
2002	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:46.39891
2003	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:51.49498
2004	driver1	-1.3913811	36.7634577	0	2025-04-29 12:29:56.495681
2005	driver1	-1.3913811	36.7634577	0	2025-04-29 12:30:01.496186
2006	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:01.944238
2007	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:06.516621
2008	driver1	-4.05466	39.6636	0	2025-04-29 12:30:06.935105
2009	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:11.517518
2010	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:16.623976
2011	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:21.624689
2012	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:26.969573
2013	driver1	-4.05466	39.6636	0	2025-04-29 12:30:28.718535
2014	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:32.212811
2015	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:37.213091
2016	driver1	-4.05466	39.6636	0	2025-04-29 12:30:38.375865
2017	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:42.213757
2018	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:47.214118
2019	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:52.2149
2020	driver1	-1.31864	36.8352	0	2025-04-29 12:30:56.956941
2021	driver1	-1.3913825	36.7634485	0	2025-04-29 12:30:57.235834
2022	driver1	-1.3913825	36.7634485	0	2025-04-29 12:31:02.23647
2023	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:05.603624
2024	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:07.254555
2025	driver1	-1.31864	36.8352	0	2025-04-29 12:31:08.853026
2026	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:12.343241
2027	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:17.764301
2028	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:23.107641
2029	driver1	-1.31864	36.8352	0	2025-04-29 12:31:25.104778
2030	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:28.606511
2031	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:33.606964
2032	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:38.607469
2033	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:43.607849
2034	driver1	-1.31864	36.8352	0	2025-04-29 12:31:43.7121
2035	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:48.608377
2036	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:53.608698
2037	driver1	-1.3913873	36.7634541	0	2025-04-29 12:31:58.609649
2038	driver1	-1.3913873	36.7634541	0	2025-04-29 12:32:03.67323
2039	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:06.035674
2040	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:08.68645
2041	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:13.686891
2042	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:18.687415
2043	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:23.688106
2044	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:29.129172
2045	driver1	-1.31864	36.8352	0	2025-04-29 12:32:31.637402
2046	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:34.129969
2047	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:39.130346
2048	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:44.533607
2049	driver1	-1.31864	36.8352	0	2025-04-29 12:32:47.123651
2050	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:49.635486
2051	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:54.636141
2052	driver1	-1.3913848	36.7634572	0	2025-04-29 12:32:59.637193
2053	driver1	-1.31864	36.8352	0	2025-04-29 12:33:03.688526
2054	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:04.003284
2055	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:08.710104
2056	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:13.710349
2057	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:18.710977
2058	driver1	-1.31864	36.8352	0	2025-04-29 12:33:19.760092
2059	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:24.26782
2060	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:29.274159
2061	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:34.432767
2062	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:39.433437
2063	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:44.434286
2064	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:49.799231
2065	driver1	-1.3913843	36.7634494	0	2025-04-29 12:33:55.134812
2066	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:00.135344
2067	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:05.136383
2068	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:05.154604
2069	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:10.155423
2070	driver1	-1.31864	36.8352	0	2025-04-29 12:34:13.038888
2071	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:15.155704
2072	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:20.156094
2073	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:25.218849
2074	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:30.219167
2075	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:35.219563
2076	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:40.220018
2077	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:45.763164
2078	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:50.763535
2079	driver1	-1.3913843	36.7634494	0	2025-04-29 12:34:55.765601
2080	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:00.764358
2081	driver1	-1.31864	36.8352	0	2025-04-29 12:35:05.335325
2082	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:05.353003
2083	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:10.351362
2084	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:15.3518
2085	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:20.352203
2086	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:25.35275
2087	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:30.358499
2088	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:35.358944
2089	driver1	-1.31864	36.8352	0	2025-04-29 12:35:36.511353
2090	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:40.359551
2091	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:45.913252
2092	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:50.913696
2093	driver1	-1.3913843	36.7634494	0	2025-04-29 12:35:56.425477
2094	driver1	-1.3913843	36.7634494	0	2025-04-29 12:36:01.474253
2095	driver1	-1.3913843	36.7634494	0	2025-04-29 12:36:06.475222
2096	driver1	-1.3913843	36.7634494	0	2025-04-29 12:36:11.733671
2097	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:13.46149
2098	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:16.765285
2099	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:21.894937
2100	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:26.894231
2101	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:31.903059
2102	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:36.902839
2103	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:41.903166
2104	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:46.906351
2105	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:52.136154
2106	driver1	-1.31864	36.8352	0	2025-04-29 12:36:55.714759
2107	driver1	-1.3913906	36.7634521	0	2025-04-29 12:36:57.208185
2108	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:02.208559
2109	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:07.522849
2110	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:07.543743
2111	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:12.544815
2112	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:17.545478
2113	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:22.545673
2114	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:27.546313
2115	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:32.553168
2116	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:37.552699
2117	driver1	-1.31864	36.8352	0	2025-04-29 12:37:42.502068
2118	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:42.552488
2119	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:47.552903
2120	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:52.55332
2121	driver1	-1.3913906	36.7634521	0	2025-04-29 12:37:57.633255
2122	driver1	-1.31864	36.8352	0	2025-04-29 12:37:59.038322
2123	driver1	-1.3913906	36.7634521	0	2025-04-29 12:38:02.631555
2124	driver1	-1.3913906	36.7634521	0	2025-04-29 12:38:07.915279
2125	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:09.665292
2126	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:13.177147
2127	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:18.17779
2128	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:23.178186
2129	driver1	-1.31864	36.8352	0	2025-04-29 12:38:25.990505
2130	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:28.496183
2131	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:33.770495
2132	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:38.770979
2133	driver1	-1.31864	36.8352	0	2025-04-29 12:38:42.220046
2134	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:43.771267
2135	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:48.771715
2136	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:53.772157
2137	driver1	-1.3913817	36.7634573	0	2025-04-29 12:38:58.772811
2138	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:04.0544
2139	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:08.551202
2140	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:13.551444
2141	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:19.009917
2142	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:23.898467
2143	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:28.898294
2144	driver1	-1.31864	36.8352	0	2025-04-29 12:39:28.906931
2145	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:33.906234
2146	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:38.906358
2147	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:43.906917
2148	driver1	-1.31864	36.8352	0	2025-04-29 12:39:44.669525
2149	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:49.18007
2150	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:54.180316
2151	driver1	-1.3913817	36.7634573	0	2025-04-29 12:39:59.180725
2152	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:04.18129
2153	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:08.566011
2154	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:14.009164
2155	driver1	-1.31864	36.8352	0	2025-04-29 12:40:18.790178
2156	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:19.085801
2157	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:24.078959
2158	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:29.383099
2159	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:34.383377
2160	driver1	-1.31864	36.8352	0	2025-04-29 12:40:35.852418
2161	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:39.383878
2162	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:44.384067
2163	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:49.384651
2164	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:54.385497
2165	driver1	-1.3913817	36.7634573	0	2025-04-29 12:40:59.386837
2166	driver1	-1.31864	36.8352	0	2025-04-29 12:41:00.803026
2167	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:01.802302
2168	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:01.821703
2169	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:06.819448
2170	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:08.546227
2171	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:08.731316
2172	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:08.75827
2173	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:10.092872
2174	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:11.517092
2175	driver1	-1.31864	36.8352	0	2025-04-29 12:41:11.792679
2176	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:16.511938
2177	driver1	-1.31864	36.8352	0	2025-04-29 12:41:20.115846
2178	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:21.512572
2179	driver1	-1.31864	36.8352	0	2025-04-29 12:41:25.821698
2180	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:26.513304
2181	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:31.51481
2182	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:36.514863
2183	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:41.515494
2184	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:46.89261
2185	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:51.890704
2186	driver1	-1.3913817	36.7634573	0	2025-04-29 12:41:56.891425
2187	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:01.89175
2188	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:06.892138
2189	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:08.995677
2190	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:14.490679
2191	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:19.491102
2192	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:24.497172
2193	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:30.091818
2194	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:35.098368
2195	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:40.098785
2196	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:40.27395
2197	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:40.290202
2198	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:45.291601
2199	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:46.228917
2200	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:46.252746
2201	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:47.574415
2202	driver1	-1.31864	36.8352	0	2025-04-29 12:42:49.702336
2203	driver1	-1.31864	36.8352	0	2025-04-29 12:42:52.224547
2204	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:52.595199
2205	driver1	-1.31864	36.8352	0	2025-04-29 12:42:54.56618
2206	driver1	-1.3913817	36.7634573	0	2025-04-29 12:42:58.054465
2207	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:03.294797
2208	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:08.683523
2209	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:09.086114
2210	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:14.592342
2211	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:19.922524
2212	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:24.923229
2213	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:30.332788
2214	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:35.340119
2215	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:40.339138
2216	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:45.339854
2217	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:50.340415
2218	driver1	-1.3913817	36.7634573	0	2025-04-29 12:43:55.345433
2219	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:00.346013
2220	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:05.345198
2221	driver1	-1.31864	36.8352	0	2025-04-29 12:44:05.571623
2222	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:09.114075
2223	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:14.114493
2224	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:19.114869
2225	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:24.517267
2226	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:29.518698
2227	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:34.52024
2228	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:40.107839
2229	driver1	-1.31864	36.8352	0	2025-04-29 12:44:40.690245
2230	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:45.108146
2231	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:50.109083
2232	driver1	-1.31864	36.8352	0	2025-04-29 12:44:52.150136
2233	driver1	-1.3913817	36.7634573	0	2025-04-29 12:44:55.109107
2234	driver1	-1.3913817	36.7634573	0	2025-04-29 12:45:00.519236
2235	driver1	-1.3913817	36.7634573	0	2025-04-29 12:45:05.51867
2236	driver1	-1.31864	36.8352	0	2025-04-29 12:45:06.726753
2237	driver1	-1.3913817	36.7634573	0	2025-04-29 12:45:10.519437
2238	driver1	-1.3913817	36.7634573	0	2025-04-29 12:45:10.546712
2239	driver1	-1.3913817	36.7634573	0	2025-04-29 12:45:15.546859
2240	driver1	-1.31864	36.8352	0	2025-04-29 12:45:18.507138
2241	driver1	-1.3913817	36.7634573	0	2025-04-29 12:45:19.581873
2242	driver1	-1.3913817	36.7634573	0	2025-04-29 12:45:19.60624
2243	driver1	-1.31864	36.8352	0	2025-04-29 12:45:24.312855
2244	driver1	-1.3913788	36.7634562	0	2025-04-29 12:45:27.771065
2245	driver1	-1.3913788	36.7634562	0	2025-04-29 12:45:27.861401
2246	driver1	-1.3913788	36.7634562	0	2025-04-29 12:45:27.867
2247	driver1	-1.3913788	36.7634562	0	2025-04-29 12:45:30.270245
2248	driver1	-1.3913788	36.7634562	0	2025-04-29 12:45:35.341251
2249	driver1	-1.3913788	36.7634562	0	2025-04-29 12:45:40.34157
2250	driver1	-1.3913788	36.7634562	0	2025-04-29 12:45:45.341763
2251	driver1	-1.3913788	36.7634562	0	2025-04-29 12:45:50.342419
2252	driver1	-1.3913788	36.7634562	0	2025-04-29 12:45:55.342764
2253	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:00.348516
2254	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:05.34971
2255	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:10.549077
2256	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:10.580663
2257	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:15.61057
2258	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:20.610654
2259	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:25.69142
2260	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:30.691887
2261	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:36.145032
2262	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:41.605934
2263	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:46.606906
2264	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:51.607273
2265	driver1	-1.3913788	36.7634562	0	2025-04-29 12:46:56.988746
2266	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:01.988031
2267	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:07.146899
2268	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:12.140025
2269	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:12.161
2270	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:17.160673
2271	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:22.161237
2272	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:27.162249
2273	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:32.162296
2274	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:37.169763
2275	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:42.170101
2276	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:47.52393
2277	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:52.524335
2278	driver1	-1.3913788	36.7634562	0	2025-04-29 12:47:57.633838
2279	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:02.633898
2280	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:07.691727
2281	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:12.28271
2282	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:17.283415
2283	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:22.283194
2284	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:27.820815
2285	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:32.821275
2286	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:37.827441
2287	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:42.827628
2288	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:47.828353
2289	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:52.829116
2290	driver1	-1.3913788	36.7634562	0	2025-04-29 12:48:57.834115
2291	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:03.159848
2292	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:08.160192
2293	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:13.162254
2294	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:13.193017
2295	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:18.192555
2296	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:23.325953
2297	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:28.326383
2298	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:33.327419
2299	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:38.327111
2300	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:43.327923
2301	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:48.328088
2302	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:53.330707
2303	driver1	-1.3913788	36.7634562	0	2025-04-29 12:49:58.333716
2304	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:03.334472
2305	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:08.334975
2306	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:13.34062
2307	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:13.351599
2308	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:18.452421
2309	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:23.452817
2310	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:28.453246
2311	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:33.453778
2312	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:38.460055
2313	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:43.460227
2314	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:48.461414
2315	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:53.461345
2316	driver1	-1.3913788	36.7634562	0	2025-04-29 12:50:58.461816
2317	driver1	-1.3913788	36.7634562	0	2025-04-29 12:51:03.462419
2318	driver1	-1.3913788	36.7634562	0	2025-04-29 12:51:08.513125
2319	driver1	-1.2841	36.8155	0	2025-04-29 12:55:53.166499
2320	driver1	-1.2841	36.8155	0	2025-04-29 12:55:53.261236
2321	driver1	-1.2841	36.8155	0	2025-04-29 12:56:49.72425
2322	driver1	-1.2841	36.8155	0	2025-04-29 12:56:49.734838
2323	driver1	-1.2841	36.8155	0	2025-04-29 12:56:49.966263
2324	driver1	-1.2841	36.8155	0	2025-04-29 12:56:51.732476
2325	driver1	-1.2841	36.8155	0	2025-04-29 13:08:58.649532
2326	driver1	-1.2841	36.8155	0	2025-04-29 13:08:58.671722
2327	driver1	-1.2841	36.8155	0	2025-04-29 13:08:58.688525
2328	driver1	-1.2841	36.8155	0	2025-04-29 13:09:00.376388
2329	driver1	-1.2841	36.8155	0	2025-04-29 13:09:39.447678
2330	driver1	-1.2841	36.8155	0	2025-04-29 13:09:39.464555
2331	driver1	-1.2841	36.8155	0	2025-04-29 13:09:39.880255
2332	driver1	-1.2841	36.8155	0	2025-04-29 13:09:41.20396
2333	driver1	-1.2841	36.8155	0	2025-04-29 13:18:55.143598
2334	driver1	-1.2841	36.8155	0	2025-04-29 13:18:55.165866
2335	driver1	-1.2841	36.8155	0	2025-04-29 13:18:55.183411
2336	driver1	-1.2841	36.8155	0	2025-04-29 13:18:56.962779
2337	driver1	-1.2841	36.8155	0	2025-04-29 13:30:15.762282
2338	driver1	-1.2841	36.8155	0	2025-04-29 13:30:17.621084
2339	driver1	-1.2841	36.8155	0	2025-04-29 13:30:20.981644
2340	driver1	-1.2841	36.8155	0	2025-04-29 13:30:21.024245
2341	driver1	-1.2841	36.8155	0	2025-04-29 13:30:21.049259
2342	driver1	-1.2841	36.8155	0	2025-04-29 13:30:22.265062
2343	driver1	-1.2841	36.8155	0	2025-04-29 13:31:29.94625
2344	driver1	-1.2841	36.8155	0	2025-04-29 13:31:29.961251
2345	driver1	-1.2841	36.8155	0	2025-04-29 13:31:30.44325
2346	driver1	-1.2841	36.8155	0	2025-04-29 13:31:31.761253
2347	driver1	-1.2841	36.8155	0	2025-04-29 14:24:14.32726
2348	driver1	-1.2841	36.8155	0	2025-04-29 14:24:14.435247
2349	driver1	-1.2841	36.8155	0	2025-04-29 14:24:14.458264
2350	driver1	-1.2841	36.8155	0	2025-04-29 14:24:15.775629
2351	driver1	-1.2841	36.8155	0	2025-04-29 14:27:06.528497
2352	driver1	-1.2841	36.8155	0	2025-04-29 14:27:08.482974
2353	driver1	-1.2841	36.8155	0	2025-04-29 14:27:14.544734
2354	driver1	-1.2841	36.8155	0	2025-04-29 14:27:14.603721
2355	driver1	-1.2841	36.8155	0	2025-04-29 14:27:15.107246
2356	driver1	-1.2841	36.8155	0	2025-04-29 14:27:15.501866
2357	driver1	-1.2841	36.8155	0	2025-04-29 14:35:46.427937
2358	driver1	-1.2841	36.8155	0	2025-04-29 14:35:46.477869
2359	driver1	-1.2841	36.8155	0	2025-04-29 14:35:46.960673
2360	driver1	-1.2841	36.8155	0	2025-04-29 14:35:47.738765
2361	driver1	-1.2841	36.8155	0	2025-04-29 14:38:09.855504
2362	driver1	-1.2841	36.8155	0	2025-04-29 14:38:09.915595
2363	driver1	-1.2841	36.8155	0	2025-04-29 14:38:10.592316
2364	driver1	-1.2841	36.8155	0	2025-04-29 14:38:12.38804
2365	driver1	-1.2841	36.8155	0	2025-04-29 14:38:54.336285
2366	driver1	-1.2841	36.8155	0	2025-04-29 14:38:54.476256
2367	driver1	-1.2841	36.8155	0	2025-04-29 14:38:54.508489
2368	driver1	-1.2841	36.8155	0	2025-04-29 14:38:55.988708
2369	driver1	-1.2841	36.8155	0	2025-04-29 14:40:32.016281
2370	driver1	-1.2841	36.8155	0	2025-04-29 14:40:32.147345
2371	driver1	-1.2841	36.8155	0	2025-04-29 14:40:32.273899
2372	driver1	-1.2841	36.8155	0	2025-04-29 14:40:33.679704
2373	driver1	-1.2841	36.8155	0	2025-04-29 14:48:04.839251
2374	driver1	-1.2841	36.8155	0	2025-04-29 14:48:05.074253
2375	driver1	-1.2841	36.8155	0	2025-04-29 14:48:05.548625
2376	driver1	-1.2841	36.8155	0	2025-04-29 14:48:07.762993
2377	driver1	-1.2841	36.8155	0	2025-04-29 14:51:55.151295
2378	driver1	-1.2841	36.8155	0	2025-04-29 14:51:57.132218
2379	driver1	-1.2841	36.8155	0	2025-04-29 14:53:07.964359
2380	driver1	-1.2841	36.8155	0	2025-04-29 14:53:08.002694
2381	driver1	-1.2841	36.8155	0	2025-04-29 14:53:08.128272
2382	driver1	-1.2841	36.8155	0	2025-04-29 14:53:09.324123
2383	driver1	-1.2841	36.8155	0	2025-04-29 15:26:30.033277
2384	driver1	-1.2841	36.8155	0	2025-04-29 15:26:32.669922
2385	driver1	-1.2841	36.8155	0	2025-04-29 15:26:36.990569
2386	driver1	-1.2841	36.8155	0	2025-04-29 15:44:12.20654
2387	driver1	-1.2841	36.8155	0	2025-04-29 15:44:19.165246
2388	driver1	-1.2841	36.8155	0	2025-04-29 15:45:34.524555
2389	driver1	-1.2841	36.8155	0	2025-04-29 15:46:26.096253
2390	driver1	-1.2841	36.8155	0	2025-04-29 16:35:21.198712
2391	driver1	-1.2841	36.8155	0	2025-04-29 17:29:20.847283
2392	driver1	-1.2841	36.8155	0	2025-04-29 17:29:22.112497
2393	driver1	-1.2841	36.8155	0	2025-04-29 17:29:22.118761
2394	driver1	-1.2841	36.8155	0	2025-04-29 17:29:22.459955
2395	driver1	-1.2841	36.8155	0	2025-04-29 17:30:53.578385
2396	driver1	-1.2841	36.8155	0	2025-04-29 17:30:53.629271
2397	driver1	-1.2841	36.8155	0	2025-04-29 17:30:53.638561
2398	driver1	-1.2841	36.8155	0	2025-04-29 17:30:55.138446
2399	driver1	-1.2841	36.8155	0	2025-04-29 17:56:31.175587
2400	driver1	-1.2841	36.8155	0	2025-04-29 17:56:32.213479
2401	driver1	-1.2841	36.8155	0	2025-04-29 17:56:46.046085
2402	driver1	-1.2841	36.8155	0	2025-04-29 17:56:46.051735
2403	driver1	-1.2841	36.8155	0	2025-04-29 17:56:46.290262
2404	driver1	-1.2841	36.8155	0	2025-04-29 17:56:47.398593
2405	driver1	-1.2841	36.8155	0	2025-04-29 17:58:21.366389
2406	driver1	-1.2841	36.8155	0	2025-04-29 17:58:23.318184
2407	driver1	-1.2841	36.8155	0	2025-04-29 18:03:35.143801
2408	driver1	-1.2841	36.8155	0	2025-04-29 18:03:38.34456
2409	driver1	-1.2841	36.8155	0	2025-04-29 18:07:51.033136
2410	driver1	-1.2841	36.8155	0	2025-04-29 18:07:51.04827
2411	driver1	-1.2841	36.8155	0	2025-04-29 18:07:51.144073
2412	driver1	-1.2841	36.8155	0	2025-04-29 18:07:52.424838
2413	driver1	-1.2841	36.8155	0	2025-04-29 18:08:40.532252
2414	driver1	-1.2841	36.8155	0	2025-04-29 18:08:40.622045
2415	driver1	-1.2841	36.8155	0	2025-04-29 18:08:40.643317
2416	driver1	-1.2841	36.8155	0	2025-04-29 18:08:41.914861
2417	driver1	-1.2841	36.8155	0	2025-04-29 18:20:00.598301
2418	driver1	-1.2841	36.8155	0	2025-04-29 18:20:00.623907
2419	driver1	-1.2841	36.8155	0	2025-04-29 18:20:00.838247
2420	driver1	-1.2841	36.8155	0	2025-04-29 18:20:01.841631
2421	driver1	-1.2841	36.8155	0	2025-04-29 18:20:49.672293
2422	driver1	-1.2841	36.8155	0	2025-04-29 18:20:49.706714
2423	driver1	-1.2841	36.8155	0	2025-04-29 18:20:49.913247
2424	driver1	-1.2841	36.8155	0	2025-04-29 18:20:51.069531
2425	driver1	-1.2841	36.8155	0	2025-04-29 18:21:18.576053
2426	driver1	-1.2841	36.8155	0	2025-04-29 18:21:18.585188
2427	driver1	-1.2841	36.8155	0	2025-04-29 18:21:18.756274
2428	driver1	-1.2841	36.8155	0	2025-04-29 18:21:19.873876
2429	driver1	-1.2841	36.8155	0	2025-04-29 18:22:03.242242
2430	driver1	-1.2841	36.8155	0	2025-04-29 18:22:32.166688
2431	driver1	-1.2841	36.8155	0	2025-04-29 18:22:35.492699
2432	driver1	-1.2841	36.8155	0	2025-04-29 18:23:12.710248
2433	driver1	-1.2841	36.8155	0	2025-04-29 18:24:08.917084
2434	driver1	-1.2841	36.8155	0	2025-04-29 18:26:14.106499
2435	driver1	-1.2841	36.8155	0	2025-04-29 18:28:26.119034
2436	driver1	-1.2841	36.8155	0	2025-04-29 18:29:29.389471
2437	driver1	-1.2841	36.8155	0	2025-04-29 18:30:27.347393
2438	driver1	-1.2841	36.8155	0	2025-04-29 18:42:13.102323
2439	driver1	-1.2841	36.8155	0	2025-04-29 18:42:18.463939
2440	driver1	-1.2841	36.8155	0	2025-04-29 18:42:18.508732
2441	driver1	-1.2841	36.8155	0	2025-04-29 18:42:18.530618
2442	driver1	-1.2841	36.8155	0	2025-04-29 18:42:19.214556
2443	driver1	-1.2841	36.8155	0	2025-04-29 18:44:02.62918
2444	driver1	-1.2841	36.8155	0	2025-04-29 18:44:02.670177
2445	driver1	-1.2841	36.8155	0	2025-04-29 18:44:02.873897
2446	driver1	-1.2841	36.8155	0	2025-04-29 18:44:04.089579
2447	driver1	-1.2841	36.8155	0	2025-04-29 19:08:26.901952
2448	driver1	-1.2841	36.8155	0	2025-04-29 19:08:28.485879
2449	driver1	-1.2841	36.8155	0	2025-04-29 19:09:13.07117
2450	driver1	-1.31864	36.8352	0	2025-04-30 06:00:13.108175
2451	driver1	-1.31864	36.8352	0	2025-04-30 06:00:25.054386
2452	driver1	-1.31864	36.8352	0	2025-04-30 06:00:49.593124
2453	driver1	-1.31864	36.8352	0	2025-04-30 06:01:06.478777
2454	driver1	-1.31864	36.8352	0	2025-04-30 06:01:31.073803
2455	driver1	-1.31864	36.8352	0	2025-04-30 06:01:42.670866
2456	driver1	-1.31864	36.8352	0	2025-04-30 06:01:58.171398
2457	driver1	-1.31864	36.8352	0	2025-04-30 06:02:26.60948
2458	driver1	-1.31864	36.8352	0	2025-04-30 06:02:41.704246
2459	driver1	-1.31864	36.8352	0	2025-04-30 06:02:56.760064
2460	driver1	-1.31864	36.8352	0	2025-04-30 06:03:11.706781
2461	driver1	-1.31864	36.8352	0	2025-04-30 06:03:57.283838
2462	driver1	-1.31864	36.8352	0	2025-04-30 06:04:12.071188
2463	driver1	-1.31864	36.8352	0	2025-04-30 06:04:40.310226
2464	driver1	-1.31864	36.8352	0	2025-04-30 06:04:55.187456
2465	driver1	-1.31864	36.8352	0	2025-04-30 06:05:14.259506
2466	driver1	-1.31864	36.8352	0	2025-04-30 06:05:26.303227
2467	driver1	-1.31864	36.8352	0	2025-04-30 06:05:40.809271
2468	driver1	-1.31864	36.8352	0	2025-04-30 06:06:10.999486
2469	driver1	-1.31864	36.8352	0	2025-04-30 06:06:25.64344
2470	driver1	-1.31864	36.8352	0	2025-04-30 06:06:40.751246
2471	driver1	-1.31864	36.8352	0	2025-04-30 06:06:56.124861
2472	driver1	-1.31864	36.8352	0	2025-04-30 06:07:10.670521
2473	driver1	-1.31864	36.8352	0	2025-04-30 06:07:24.74373
2474	driver1	-1.31864	36.8352	0	2025-04-30 06:07:39.847418
2475	driver1	-1.31864	36.8352	0	2025-04-30 06:07:56.018624
2476	driver1	-1.31864	36.8352	0	2025-04-30 06:08:26.724449
2477	driver1	-1.31864	36.8352	0	2025-04-30 06:08:42.145624
2478	driver1	-1.31864	36.8352	0	2025-04-30 06:09:27.321582
2479	driver1	-1.31864	36.8352	0	2025-04-30 06:09:57.049445
2480	driver1	-1.31864	36.8352	0	2025-04-30 06:10:09.25309
2481	driver1	-1.31864	36.8352	0	2025-04-30 06:10:24.669788
2482	driver1	-1.31864	36.8352	0	2025-04-30 06:10:38.944421
2483	driver1	-1.31864	36.8352	0	2025-04-30 06:10:53.596343
2484	driver1	-1.31864	36.8352	0	2025-04-30 06:11:09.067388
2485	driver1	-1.31864	36.8352	0	2025-04-30 06:11:20.90377
2486	driver1	-1.31864	36.8352	0	2025-04-30 06:11:40.144305
2487	driver1	-1.31864	36.8352	0	2025-04-30 06:11:55.212569
2488	driver1	-1.31864	36.8352	0	2025-04-30 06:12:09.782788
2489	driver1	-1.31864	36.8352	0	2025-04-30 06:12:25.262346
2490	driver1	-1.31864	36.8352	0	2025-04-30 06:12:40.448342
2491	driver1	-1.31864	36.8352	0	2025-04-30 06:12:56.539996
2492	driver1	-1.31864	36.8352	0	2025-04-30 06:13:26.003014
2493	driver1	-1.31864	36.8352	0	2025-04-30 06:13:56.943092
2494	driver1	-1.31864	36.8352	0	2025-04-30 06:14:11.346615
2495	driver1	-1.31864	36.8352	0	2025-04-30 06:14:29.114675
2496	driver1	-1.31864	36.8352	0	2025-04-30 06:16:16.235286
2497	driver1	-1.31864	36.8352	0	2025-04-30 06:16:59.344721
2498	driver1	-1.31864	36.8352	0	2025-04-30 06:17:28.92319
2499	driver1	-1.31864	36.8352	0	2025-04-30 06:17:44.454155
2500	driver1	-1.31864	36.8352	0	2025-04-30 06:17:58.908845
2501	driver1	-1.31864	36.8352	0	2025-04-30 06:18:29.18411
2502	driver1	-1.31864	36.8352	0	2025-04-30 06:18:42.573676
2503	driver1	-1.31864	36.8352	0	2025-04-30 06:19:27.136007
2504	driver1	-1.31864	36.8352	0	2025-04-30 06:19:41.883458
2505	driver1	-1.31864	36.8352	0	2025-04-30 06:19:57.722504
2506	driver1	-1.31864	36.8352	0	2025-04-30 06:20:12.816961
2507	driver1	-1.31864	36.8352	0	2025-04-30 06:20:44.830027
2508	driver1	-1.31864	36.8352	0	2025-04-30 06:20:58.880071
2509	driver1	-1.31864	36.8352	0	2025-04-30 06:21:17.001866
2510	driver1	-1.31864	36.8352	0	2025-04-30 06:21:32.720416
2511	driver1	-1.31864	36.8352	0	2025-04-30 06:21:46.79359
2512	driver1	-1.31864	36.8352	0	2025-04-30 06:22:00.831681
2513	driver1	-1.31864	36.8352	0	2025-04-30 06:22:15.070643
2514	driver1	-1.31864	36.8352	0	2025-04-30 06:22:29.788602
2515	driver1	-1.31864	36.8352	0	2025-04-30 06:22:47.124545
2516	driver1	-1.31864	36.8352	0	2025-04-30 06:23:44.581349
2517	driver1	-1.31864	36.8352	0	2025-04-30 06:24:55.874177
2518	driver1	-1.31864	36.8352	0	2025-04-30 06:25:13.133859
2519	driver1	-1.31864	36.8352	0	2025-04-30 06:25:28.388174
2520	driver1	-1.31864	36.8352	0	2025-04-30 06:25:58.806972
2521	driver1	-1.31864	36.8352	0	2025-04-30 06:26:13.684714
2522	driver1	-1.31864	36.8352	0	2025-04-30 06:26:28.875652
2523	driver1	-1.31864	36.8352	0	2025-04-30 06:26:43.7556
2524	driver1	-1.31864	36.8352	0	2025-04-30 06:26:59.864604
2525	driver1	-1.31864	36.8352	0	2025-04-30 06:27:30.771495
2526	driver1	-1.31864	36.8352	0	2025-04-30 06:27:44.571799
2527	driver1	-1.31864	36.8352	0	2025-04-30 06:30:11.908703
2528	driver1	-1.31864	36.8352	0	2025-04-30 06:34:01.605414
2529	driver1	-1.31864	36.8352	0	2025-04-30 06:34:26.894192
2530	driver1	-1.31864	36.8352	0	2025-04-30 06:34:41.440466
2531	driver1	-1.31864	36.8352	0	2025-04-30 06:34:56.053095
2532	driver1	-1.31864	36.8352	0	2025-04-30 06:35:10.708038
2533	driver1	-1.31864	36.8352	0	2025-04-30 06:35:38.781569
2534	driver1	-1.31864	36.8352	0	2025-04-30 06:35:53.695911
2535	driver1	-1.31864	36.8352	0	2025-04-30 06:36:23.114105
2536	driver1	-1.31864	36.8352	0	2025-04-30 06:36:39.191241
2537	driver1	-1.31864	36.8352	0	2025-04-30 06:37:09.157476
2538	driver1	-1.31864	36.8352	0	2025-04-30 06:37:22.812355
2539	driver1	-1.31864	36.8352	0	2025-04-30 06:37:37.927347
2540	driver1	-1.31864	36.8352	0	2025-04-30 06:37:52.810385
2541	driver1	-1.31864	36.8352	0	2025-04-30 06:38:08.056651
2542	driver1	-1.31864	36.8352	0	2025-04-30 06:38:23.180541
2543	driver1	-1.31864	36.8352	0	2025-04-30 06:38:37.858125
2544	driver1	-1.31864	36.8352	0	2025-04-30 06:38:56.295514
2545	driver1	-1.31864	36.8352	0	2025-04-30 06:39:10.930544
2546	driver1	-1.31864	36.8352	0	2025-04-30 06:39:25.817497
2547	driver1	-1.31864	36.8352	0	2025-04-30 06:39:40.713157
2548	driver1	-1.31864	36.8352	0	2025-04-30 06:40:00.848543
2549	driver1	-1.31864	36.8352	0	2025-04-30 06:40:11.011963
2550	driver1	-1.31864	36.8352	0	2025-04-30 06:40:28.085648
2551	driver1	-1.31864	36.8352	0	2025-04-30 06:40:55.907476
2552	driver1	-1.31864	36.8352	0	2025-04-30 06:41:12.14192
2553	driver1	-1.31864	36.8352	0	2025-04-30 06:41:25.086913
2554	driver1	-1.31864	36.8352	0	2025-04-30 06:41:40.298815
2555	driver1	-1.31864	36.8352	0	2025-04-30 06:41:55.638241
2556	driver1	-1.31864	36.8352	0	2025-04-30 06:42:22.833352
2557	driver1	-1.31864	36.8352	0	2025-04-30 06:42:36.03448
2558	driver1	-1.31864	36.8352	0	2025-04-30 06:42:50.76278
2559	driver1	-1.31864	36.8352	0	2025-04-30 06:43:05.567443
2560	driver1	-1.31864	36.8352	0	2025-04-30 06:43:20.674675
2561	driver1	-1.31864	36.8352	0	2025-04-30 06:43:35.905582
2562	driver1	-1.31864	36.8352	0	2025-04-30 06:44:28.703949
2563	driver1	-1.31864	36.8352	0	2025-04-30 06:44:58.635544
2564	driver1	-1.31864	36.8352	0	2025-04-30 06:45:13.524062
2565	driver1	-1.31864	36.8352	0	2025-04-30 06:45:30.003493
2566	driver1	-1.31864	36.8352	0	2025-04-30 06:45:43.687568
2567	driver1	-1.31864	36.8352	0	2025-04-30 06:45:58.64935
2568	driver1	-1.31864	36.8352	0	2025-04-30 06:46:42.779318
2569	driver1	-1.31864	36.8352	0	2025-04-30 06:46:57.75051
2570	driver1	-1.31864	36.8352	0	2025-04-30 06:47:12.841754
2571	driver1	-1.31864	36.8352	0	2025-04-30 06:47:27.804822
2572	driver1	-1.31864	36.8352	0	2025-04-30 06:47:43.83059
2573	driver1	-1.31864	36.8352	0	2025-04-30 06:47:58.807469
2574	driver1	-1.31864	36.8352	0	2025-04-30 06:48:12.766984
2575	driver1	-1.31864	36.8352	0	2025-04-30 06:48:27.752075
2576	driver1	-1.31864	36.8352	0	2025-04-30 06:48:42.755909
2577	driver1	-1.31864	36.8352	0	2025-04-30 06:49:12.775854
2578	driver1	-1.31864	36.8352	0	2025-04-30 06:49:27.858587
2579	driver1	-1.31864	36.8352	0	2025-04-30 06:49:57.553507
2580	driver1	-1.31864	36.8352	0	2025-04-30 06:50:12.688506
2581	driver1	-1.31864	36.8352	0	2025-04-30 06:50:27.686293
2582	driver1	-1.31864	36.8352	0	2025-04-30 06:50:42.926508
2583	driver1	-1.31864	36.8352	0	2025-04-30 06:50:58.051588
2584	driver1	-1.31864	36.8352	0	2025-04-30 06:51:25.702997
2585	driver1	-1.31864	36.8352	0	2025-04-30 06:51:41.801476
2586	driver1	-1.31864	36.8352	0	2025-04-30 06:51:56.107075
2587	driver1	-1.31864	36.8352	0	2025-04-30 06:52:11.990249
2588	driver1	-1.31864	36.8352	0	2025-04-30 06:52:25.783965
2589	driver1	-1.31864	36.8352	0	2025-04-30 06:52:41.743698
2590	driver1	-1.31864	36.8352	0	2025-04-30 06:52:55.75076
2591	driver1	-1.31864	36.8352	0	2025-04-30 06:53:11.40271
2592	driver1	-1.31864	36.8352	0	2025-04-30 06:53:39.911255
2593	driver1	-1.31864	36.8352	0	2025-04-30 06:53:55.008849
2594	driver1	-1.31864	36.8352	0	2025-04-30 06:54:11.630267
2595	driver1	-1.31864	36.8352	0	2025-04-30 06:54:26.836524
2596	driver1	-1.31864	36.8352	0	2025-04-30 06:54:42.931437
2597	driver1	-1.31864	36.8352	0	2025-04-30 06:54:56.556518
2598	driver1	-1.31864	36.8352	0	2025-04-30 06:55:11.679744
2599	driver1	-1.31864	36.8352	0	2025-04-30 06:55:26.714586
2600	driver1	-1.31864	36.8352	0	2025-04-30 06:55:42.706424
2601	driver1	-1.31864	36.8352	0	2025-04-30 06:55:57.447101
2602	driver1	-1.31864	36.8352	0	2025-04-30 06:56:12.604857
2603	driver1	-1.31864	36.8352	0	2025-04-30 06:56:27.067701
2604	driver1	-1.31864	36.8352	0	2025-04-30 06:56:42.73465
2605	driver1	-1.31864	36.8352	0	2025-04-30 06:56:57.708101
2606	driver1	-1.31864	36.8352	0	2025-04-30 06:57:12.626811
2607	driver1	-1.31864	36.8352	0	2025-04-30 06:57:27.642131
2608	driver1	-1.31864	36.8352	0	2025-04-30 06:57:42.754419
2609	driver1	-1.31864	36.8352	0	2025-04-30 06:57:57.915021
2610	driver1	-1.31864	36.8352	0	2025-04-30 06:58:11.518453
2611	driver1	-1.31864	36.8352	0	2025-04-30 06:58:42.271404
2612	driver1	-1.31864	36.8352	0	2025-04-30 06:58:56.87139
2613	driver1	-1.31864	36.8352	0	2025-04-30 06:59:27.158541
2614	driver1	-1.31864	36.8352	0	2025-04-30 06:59:42.576247
2615	driver1	-1.31864	36.8352	0	2025-04-30 06:59:57.893257
2616	driver1	-1.31864	36.8352	0	2025-04-30 07:00:42.57272
2617	driver1	-1.31864	36.8352	0	2025-04-30 07:00:57.75233
2618	driver1	-1.31864	36.8352	0	2025-04-30 07:01:13.109994
2619	driver1	-1.31864	36.8352	0	2025-04-30 07:01:27.694404
2620	driver1	-1.31864	36.8352	0	2025-04-30 07:01:42.806761
2621	driver1	-1.31864	36.8352	0	2025-04-30 07:01:58.976715
2622	driver1	-1.31864	36.8352	0	2025-04-30 07:02:14.189819
2623	driver1	-1.31864	36.8352	0	2025-04-30 07:02:40.681883
2624	driver1	-1.31864	36.8352	0	2025-04-30 07:02:54.79993
2625	driver1	-1.31864	36.8352	0	2025-04-30 07:03:40.074387
2626	driver1	-1.31864	36.8352	0	2025-04-30 07:03:58.896579
2627	driver1	-1.31864	36.8352	0	2025-04-30 07:04:13.87844
2628	driver1	-1.31864	36.8352	0	2025-04-30 07:04:28.581461
2629	driver1	-1.31864	36.8352	0	2025-04-30 07:04:45.612496
2630	driver1	-1.31864	36.8352	0	2025-04-30 07:05:00.638095
2631	driver1	-1.31864	36.8352	0	2025-04-30 07:05:15.76766
2632	driver1	-1.31864	36.8352	0	2025-04-30 07:05:32.194129
2633	driver1	-1.31864	36.8352	0	2025-04-30 07:05:46.415524
2634	driver1	-1.31864	36.8352	0	2025-04-30 07:06:00.751447
2635	driver1	-1.31864	36.8352	0	2025-04-30 07:06:14.563047
2636	driver1	-1.31864	36.8352	0	2025-04-30 07:06:31.086983
2637	driver1	-1.31864	36.8352	0	2025-04-30 07:06:44.528331
2638	driver1	-1.31864	36.8352	0	2025-04-30 07:07:00.387832
2639	driver1	-1.31864	36.8352	0	2025-04-30 07:07:13.60516
2640	driver1	-1.31864	36.8352	0	2025-04-30 07:07:28.705082
2641	driver1	-1.31864	36.8352	0	2025-04-30 07:07:43.815615
2642	driver1	-1.31864	36.8352	0	2025-04-30 07:07:58.515528
2643	driver1	-1.31864	36.8352	0	2025-04-30 07:08:14.289477
2644	driver1	-1.31864	36.8352	0	2025-04-30 07:08:27.694566
2645	driver1	-1.31864	36.8352	0	2025-04-30 07:08:42.99034
2646	driver1	-1.31864	36.8352	0	2025-04-30 07:09:00.47067
2647	driver1	-1.31864	36.8352	0	2025-04-30 07:09:13.632362
2648	driver1	-1.31864	36.8352	0	2025-04-30 07:09:44.510767
2649	driver1	-1.31864	36.8352	0	2025-04-30 07:10:14.569651
2650	driver1	-1.31864	36.8352	0	2025-04-30 07:10:29.607881
2651	driver1	-1.31864	36.8352	0	2025-04-30 07:10:44.823032
2652	driver1	-1.31864	36.8352	0	2025-04-30 07:11:00.915825
2653	driver1	-1.31864	36.8352	0	2025-04-30 07:11:31.743423
2654	driver1	-1.31864	36.8352	0	2025-04-30 07:11:46.683841
2655	driver1	-1.31864	36.8352	0	2025-04-30 07:12:00.835257
2656	driver1	-1.31864	36.8352	0	2025-04-30 07:12:16.214262
2657	driver1	-1.31864	36.8352	0	2025-04-30 07:12:30.595638
2658	driver1	-1.31864	36.8352	0	2025-04-30 07:12:46.666837
2659	driver1	-1.31864	36.8352	0	2025-04-30 07:13:31.589002
2660	driver1	-1.31864	36.8352	0	2025-04-30 07:13:42.701812
2661	driver1	-1.31864	36.8352	0	2025-04-30 07:14:18.007497
2662	driver1	-1.31864	36.8352	0	2025-04-30 07:14:32.687113
2663	driver1	-1.31864	36.8352	0	2025-04-30 07:14:46.797124
2664	driver1	-1.31864	36.8352	0	2025-04-30 07:15:02.25844
2665	driver1	-1.31864	36.8352	0	2025-04-30 07:15:16.908578
2666	driver1	-1.31864	36.8352	0	2025-04-30 07:15:31.672119
2667	driver1	-1.31864	36.8352	0	2025-04-30 07:15:47.53606
2668	driver1	-1.31864	36.8352	0	2025-04-30 07:16:16.733071
2669	driver1	-1.31864	36.8352	0	2025-04-30 07:16:33.08772
2670	driver1	-1.31864	36.8352	0	2025-04-30 07:16:47.790858
2671	driver1	-1.31864	36.8352	0	2025-04-30 07:17:02.753843
2672	driver1	-1.31864	36.8352	0	2025-04-30 07:17:17.821972
2673	driver1	-1.31864	36.8352	0	2025-04-30 07:17:32.833457
2674	driver1	-1.31864	36.8352	0	2025-04-30 07:17:49.809944
2675	driver1	-1.31864	36.8352	0	2025-04-30 07:18:03.065145
2676	driver1	-1.31864	36.8352	0	2025-04-30 07:18:19.214796
2677	driver1	-1.31864	36.8352	0	2025-04-30 07:18:33.787222
2678	driver1	-1.31864	36.8352	0	2025-04-30 07:18:57.909032
2679	driver1	-1.31864	36.8352	0	2025-04-30 07:19:13.529415
2680	driver1	-1.31864	36.8352	0	2025-04-30 07:19:28.656232
2681	driver1	-1.31864	36.8352	0	2025-04-30 07:19:58.591818
2682	driver1	-1.31864	36.8352	0	2025-04-30 07:20:13.910448
2683	driver1	-1.31864	36.8352	0	2025-04-30 07:20:28.064891
2684	driver1	-1.31864	36.8352	0	2025-04-30 07:20:44.326493
2685	driver1	-1.31864	36.8352	0	2025-04-30 07:20:59.646384
2686	driver1	-1.31864	36.8352	0	2025-04-30 07:21:17.845802
2687	driver1	-1.31864	36.8352	0	2025-04-30 07:21:31.933462
2688	driver1	-1.31864	36.8352	0	2025-04-30 07:21:47.662865
2689	driver1	-1.31864	36.8352	0	2025-04-30 07:22:04.039775
2690	driver1	-1.31864	36.8352	0	2025-04-30 07:22:19.625437
2691	driver1	-1.31864	36.8352	0	2025-04-30 07:22:34.629997
2692	driver1	-1.31864	36.8352	0	2025-04-30 07:22:49.812106
2693	driver1	-1.31864	36.8352	0	2025-04-30 07:23:21.169218
2694	driver1	-1.31864	36.8352	0	2025-04-30 07:23:34.513489
2695	driver1	-1.31864	36.8352	0	2025-04-30 07:23:57.694932
2696	driver1	-1.31864	36.8352	0	2025-04-30 07:24:12.646521
2697	driver1	-1.31864	36.8352	0	2025-04-30 07:24:27.902672
2698	driver1	-1.31864	36.8352	0	2025-04-30 07:24:42.620169
2699	driver1	-1.31864	36.8352	0	2025-04-30 07:24:57.721831
2700	driver1	-1.31864	36.8352	0	2025-04-30 07:25:13.81656
2701	driver1	-1.31864	36.8352	0	2025-04-30 07:25:28.337282
2702	driver1	-1.31864	36.8352	0	2025-04-30 07:25:43.033432
2703	driver1	-1.31864	36.8352	0	2025-04-30 07:25:57.648705
2704	driver1	-1.31864	36.8352	0	2025-04-30 07:26:13.683422
2705	driver1	-1.31864	36.8352	0	2025-04-30 07:26:27.702477
2706	driver1	-1.31864	36.8352	0	2025-04-30 07:26:42.695493
2707	driver1	-1.31864	36.8352	0	2025-04-30 07:26:57.656123
2708	driver1	-1.31864	36.8352	0	2025-04-30 07:27:12.573177
2709	driver1	-1.31864	36.8352	0	2025-04-30 07:27:27.868816
2710	driver1	-1.31864	36.8352	0	2025-04-30 07:27:43.74203
2711	driver1	-1.31864	36.8352	0	2025-04-30 07:27:59.624007
2712	driver1	-1.31864	36.8352	0	2025-04-30 07:28:14.227443
2713	driver1	-1.31864	36.8352	0	2025-04-30 07:28:43.62209
2714	driver1	-1.31864	36.8352	0	2025-04-30 07:29:00.230341
2715	driver1	-1.31864	36.8352	0	2025-04-30 07:29:13.845239
2716	driver1	-1.31864	36.8352	0	2025-04-30 07:29:30.140674
2717	driver1	-1.31864	36.8352	0	2025-04-30 07:29:43.615179
2718	driver1	-1.31864	36.8352	0	2025-04-30 07:29:58.64919
2719	driver1	-1.31864	36.8352	0	2025-04-30 07:30:13.066498
2720	driver1	-1.31864	36.8352	0	2025-04-30 07:30:44.841002
2721	driver1	-1.31864	36.8352	0	2025-04-30 07:30:59.541808
2722	driver1	-1.31864	36.8352	0	2025-04-30 07:31:14.811383
2723	driver1	-1.31864	36.8352	0	2025-04-30 07:31:30.646971
2724	driver1	-1.31864	36.8352	0	2025-04-30 07:31:44.983556
2725	driver1	-1.31864	36.8352	0	2025-04-30 07:32:02.217131
2726	driver1	-1.31864	36.8352	0	2025-04-30 07:32:14.646489
2727	driver1	-1.31864	36.8352	0	2025-04-30 07:32:30.230052
2728	driver1	-1.31864	36.8352	0	2025-04-30 07:32:58.700987
2729	driver1	-1.31864	36.8352	0	2025-04-30 07:33:13.539077
2730	driver1	-1.31864	36.8352	0	2025-04-30 07:33:42.738906
2731	driver1	-1.31864	36.8352	0	2025-04-30 07:34:33.709005
2732	driver1	-1.31864	36.8352	0	2025-04-30 07:34:48.725106
2733	driver1	-1.31864	36.8352	0	2025-04-30 07:35:18.505241
2734	driver1	-1.31864	36.8352	0	2025-04-30 07:35:33.847057
2735	driver1	-1.31864	36.8352	0	2025-04-30 07:35:50.43446
2736	driver1	-1.31864	36.8352	0	2025-04-30 07:36:03.726078
2737	driver1	-1.31864	36.8352	0	2025-04-30 07:37:04.670638
2738	driver1	-1.31864	36.8352	0	2025-04-30 07:37:19.553918
2739	driver1	-1.31864	36.8352	0	2025-04-30 07:37:34.660862
2740	driver1	-1.31864	36.8352	0	2025-04-30 07:37:49.733622
2741	driver1	-1.31864	36.8352	0	2025-04-30 07:38:05.214591
2742	driver1	-1.31864	36.8352	0	2025-04-30 07:38:20.067386
2743	driver1	-1.31864	36.8352	0	2025-04-30 07:38:36.158266
2744	driver1	-1.31864	36.8352	0	2025-04-30 07:38:59.104368
2745	driver1	-1.31864	36.8352	0	2025-04-30 07:39:12.568603
2746	driver1	-1.31864	36.8352	0	2025-04-30 07:39:27.916373
2747	driver1	-1.31864	36.8352	0	2025-04-30 07:39:43.302037
2748	driver1	-1.31864	36.8352	0	2025-04-30 07:39:58.028589
2749	driver1	-1.31864	36.8352	0	2025-04-30 07:40:12.710189
2750	driver1	-1.31864	36.8352	0	2025-04-30 07:40:27.759419
2751	driver1	-1.31864	36.8352	0	2025-04-30 07:40:43.629973
2752	driver1	-1.31864	36.8352	0	2025-04-30 07:40:58.659665
2753	driver1	-1.31864	36.8352	0	2025-04-30 07:41:13.853774
2754	driver1	-1.31864	36.8352	0	2025-04-30 07:41:29.010198
2755	driver1	-1.31864	36.8352	0	2025-04-30 07:41:43.616574
2756	driver1	-1.31864	36.8352	0	2025-04-30 07:42:13.828554
2757	driver1	-1.31864	36.8352	0	2025-04-30 07:42:43.902403
2758	driver1	-1.31864	36.8352	0	2025-04-30 07:42:58.817027
2759	driver1	-1.31864	36.8352	0	2025-04-30 07:43:14.284832
2760	driver1	-1.31864	36.8352	0	2025-04-30 07:43:28.661699
2761	driver1	-1.31864	36.8352	0	2025-04-30 07:43:44.933323
2762	driver1	-1.31864	36.8352	0	2025-04-30 07:43:59.752578
2763	driver1	-1.31864	36.8352	0	2025-04-30 07:44:14.064694
2764	driver1	-1.31864	36.8352	0	2025-04-30 07:44:28.520306
2765	driver1	-1.31864	36.8352	0	2025-04-30 07:44:43.566492
2766	driver1	-1.31864	36.8352	0	2025-04-30 07:44:58.606741
2767	driver1	-1.31864	36.8352	0	2025-04-30 07:45:13.723928
2768	driver1	-1.31864	36.8352	0	2025-04-30 07:45:58.50214
2769	driver1	-1.31864	36.8352	0	2025-04-30 07:46:14.293819
2770	driver1	-1.31864	36.8352	0	2025-04-30 07:46:28.574837
2771	driver1	-1.31864	36.8352	0	2025-04-30 07:46:42.654329
2772	driver1	-1.31864	36.8352	0	2025-04-30 07:47:11.895809
2773	driver1	-1.31864	36.8352	0	2025-04-30 07:47:27.426979
2774	driver1	-1.31864	36.8352	0	2025-04-30 07:47:42.520451
2775	driver1	-1.31864	36.8352	0	2025-04-30 07:47:56.684361
2776	driver1	-1.31864	36.8352	0	2025-04-30 07:48:11.9887
2777	driver1	-1.31864	36.8352	0	2025-04-30 07:48:41.559175
2778	driver1	-1.31864	36.8352	0	2025-04-30 07:48:56.690502
2779	driver1	-1.31864	36.8352	0	2025-04-30 07:49:12.130305
2780	driver1	-1.31864	36.8352	0	2025-04-30 07:49:26.064819
2781	driver1	-1.31864	36.8352	0	2025-04-30 07:49:57.766557
2782	driver1	-1.31864	36.8352	0	2025-04-30 07:50:42.066167
2783	driver1	-1.31864	36.8352	0	2025-04-30 07:50:58.658563
2784	driver1	-1.31864	36.8352	0	2025-04-30 07:51:13.082797
2785	driver1	-1.31864	36.8352	0	2025-04-30 07:51:27.99187
2786	driver1	-1.31864	36.8352	0	2025-04-30 07:51:41.695502
2787	driver1	-1.31864	36.8352	0	2025-04-30 07:51:57.068692
2788	driver1	-1.31864	36.8352	0	2025-04-30 07:52:14.594897
2789	driver1	-1.31864	36.8352	0	2025-04-30 07:52:29.703809
2790	driver1	-1.31864	36.8352	0	2025-04-30 07:52:42.897816
2791	driver1	-1.31864	36.8352	0	2025-04-30 07:52:58.134983
2792	driver1	-1.31864	36.8352	0	2025-04-30 07:53:27.694663
2793	driver1	-1.31864	36.8352	0	2025-04-30 07:53:42.858251
2794	driver1	-1.31864	36.8352	0	2025-04-30 07:53:57.788015
2795	driver1	-1.31864	36.8352	0	2025-04-30 07:54:12.935593
2796	driver1	-1.31864	36.8352	0	2025-04-30 07:54:28.536544
2797	driver1	-1.31864	36.8352	0	2025-04-30 07:54:42.697073
2798	driver1	-1.31864	36.8352	0	2025-04-30 07:54:57.55686
2799	driver1	-1.31864	36.8352	0	2025-04-30 07:55:13.829576
2800	driver1	-1.31864	36.8352	0	2025-04-30 07:55:28.704345
2801	driver1	-1.31864	36.8352	0	2025-04-30 07:55:43.791166
2802	driver1	-1.31864	36.8352	0	2025-04-30 07:55:59.64602
2803	driver1	-1.31864	36.8352	0	2025-04-30 07:56:16.582247
2804	driver1	-1.31864	36.8352	0	2025-04-30 07:56:45.869998
2805	driver1	-1.31864	36.8352	0	2025-04-30 07:57:00.065686
2806	driver1	-1.31864	36.8352	0	2025-04-30 07:57:14.798697
2807	driver1	-1.31864	36.8352	0	2025-04-30 07:57:29.065775
2808	driver1	-1.31864	36.8352	0	2025-04-30 07:58:14.701746
2809	driver1	-1.31864	36.8352	0	2025-04-30 07:58:43.115045
2810	driver1	-1.31864	36.8352	0	2025-04-30 07:59:03.649586
2811	driver1	-1.31864	36.8352	0	2025-04-30 07:59:35.124602
2812	driver1	-1.31864	36.8352	0	2025-04-30 07:59:49.993658
2813	driver1	-1.31864	36.8352	0	2025-04-30 08:00:07.525945
2814	driver1	-1.31864	36.8352	0	2025-04-30 08:00:19.954882
2815	driver1	-1.31864	36.8352	0	2025-04-30 08:01:04.978987
2816	driver1	-1.31864	36.8352	0	2025-04-30 08:01:20.00694
2817	driver1	-1.31864	36.8352	0	2025-04-30 08:01:34.636578
2818	driver1	-1.31864	36.8352	0	2025-04-30 08:01:50.904585
2819	driver1	-1.31864	36.8352	0	2025-04-30 08:02:35.873296
2820	driver1	-1.31864	36.8352	0	2025-04-30 08:02:50.86464
2821	driver1	-1.31864	36.8352	0	2025-04-30 08:03:05.706677
2822	driver1	-1.31864	36.8352	0	2025-04-30 08:03:36.664278
2823	driver1	-1.31864	36.8352	0	2025-04-30 08:04:29.99512
2824	driver1	-1.31864	36.8352	0	2025-04-30 08:04:58.623152
2825	driver1	-1.31864	36.8352	0	2025-04-30 08:05:13.759171
2826	driver1	-1.31864	36.8352	0	2025-04-30 08:05:43.602902
2827	driver1	-1.31864	36.8352	0	2025-04-30 08:05:58.620156
2828	driver1	-1.31864	36.8352	0	2025-04-30 08:06:29.201022
2829	driver1	-1.31864	36.8352	0	2025-04-30 08:06:42.932284
2830	driver1	-1.31864	36.8352	0	2025-04-30 08:06:57.646703
2831	driver1	-1.31864	36.8352	0	2025-04-30 08:07:12.754316
2832	driver1	-1.31864	36.8352	0	2025-04-30 08:07:44.281069
2833	driver1	-1.31864	36.8352	0	2025-04-30 08:07:58.77346
2834	driver1	-1.31864	36.8352	0	2025-04-30 08:08:13.890777
2835	driver1	-1.31864	36.8352	0	2025-04-30 08:08:31.64981
2836	driver1	-1.31864	36.8352	0	2025-04-30 08:08:49.007328
2837	driver1	-1.31864	36.8352	0	2025-04-30 08:09:22.368292
2838	driver1	-1.31864	36.8352	0	2025-04-30 08:09:36.69238
2839	driver1	-1.31864	36.8352	0	2025-04-30 08:10:06.915348
2840	driver1	-1.31864	36.8352	0	2025-04-30 08:10:21.759645
2841	driver1	-1.31864	36.8352	0	2025-04-30 08:10:38.109569
2842	driver1	-1.31864	36.8352	0	2025-04-30 08:11:06.949749
2843	driver1	-1.31864	36.8352	0	2025-04-30 08:11:21.748642
2844	driver1	-1.31864	36.8352	0	2025-04-30 08:11:37.012914
2845	driver1	-1.31864	36.8352	0	2025-04-30 08:11:51.818965
2846	driver1	-1.31864	36.8352	0	2025-04-30 08:12:06.65427
2847	driver1	-1.31864	36.8352	0	2025-04-30 08:12:39.931816
2848	driver1	-1.31864	36.8352	0	2025-04-30 08:12:54.077046
2849	driver1	-1.31864	36.8352	0	2025-04-30 08:13:38.654932
2850	driver1	-1.31864	36.8352	0	2025-04-30 08:14:24.965835
2851	driver1	-1.31864	36.8352	0	2025-04-30 08:14:39.62245
2852	driver1	-1.31864	36.8352	0	2025-04-30 08:15:30.072757
2853	driver1	-1.31864	36.8352	0	2025-04-30 08:15:46.814653
2854	driver1	-1.31864	36.8352	0	2025-04-30 08:16:19.101585
2855	driver1	-1.31864	36.8352	0	2025-04-30 08:16:34.490075
2856	driver1	-1.31864	36.8352	0	2025-04-30 08:16:48.136506
2857	driver1	-1.31864	36.8352	0	2025-04-30 08:17:02.843389
2858	driver1	-1.31864	36.8352	0	2025-04-30 08:17:16.81471
2859	driver1	-1.31864	36.8352	0	2025-04-30 08:17:30.704461
2860	driver1	-1.31864	36.8352	0	2025-04-30 08:17:48.929088
2861	driver1	-1.31864	36.8352	0	2025-04-30 08:18:00.651277
2862	driver1	-1.31864	36.8352	0	2025-04-30 08:18:16.537276
2863	driver1	-1.31864	36.8352	0	2025-04-30 08:18:31.16643
2864	driver1	-1.31864	36.8352	0	2025-04-30 08:18:45.533104
2865	driver1	-1.31864	36.8352	0	2025-04-30 08:19:01.17671
2866	driver1	-1.31864	36.8352	0	2025-04-30 08:19:15.288898
2867	driver1	-1.31864	36.8352	0	2025-04-30 08:19:28.628678
2868	driver1	-1.31864	36.8352	0	2025-04-30 08:19:43.854856
2869	driver1	-1.31864	36.8352	0	2025-04-30 08:19:59.043072
2870	driver1	-1.31864	36.8352	0	2025-04-30 08:20:28.894199
2871	driver1	-1.31864	36.8352	0	2025-04-30 08:20:43.236315
2872	driver1	-1.31864	36.8352	0	2025-04-30 08:20:57.759688
2873	driver1	-1.31864	36.8352	0	2025-04-30 08:21:11.851569
2874	driver1	-1.31864	36.8352	0	2025-04-30 08:21:40.083562
2875	driver1	-1.31864	36.8352	0	2025-04-30 08:21:53.698522
2876	driver1	-1.31864	36.8352	0	2025-04-30 08:22:40.08283
2877	driver1	-1.31864	36.8352	0	2025-04-30 08:22:51.670386
2878	driver1	-1.31864	36.8352	0	2025-04-30 08:23:05.819257
2879	driver1	-1.31864	36.8352	0	2025-04-30 08:23:35.647315
2880	driver1	-1.31864	36.8352	0	2025-04-30 08:23:50.004879
2881	driver1	-1.31864	36.8352	0	2025-04-30 08:24:05.496049
2882	driver1	-1.31864	36.8352	0	2025-04-30 08:24:19.878497
2883	driver1	-1.31864	36.8352	0	2025-04-30 08:24:34.940276
2884	driver1	-1.31864	36.8352	0	2025-04-30 08:24:48.055381
2885	driver1	-1.31864	36.8352	0	2025-04-30 08:25:03.706173
2886	driver1	-1.31864	36.8352	0	2025-04-30 08:25:34.417439
2887	driver1	-1.31864	36.8352	0	2025-04-30 08:25:49.366753
2888	driver1	-1.31864	36.8352	0	2025-04-30 08:26:36.291943
2889	driver1	-1.31864	36.8352	0	2025-04-30 08:27:05.461433
2890	driver1	-1.31864	36.8352	0	2025-04-30 08:27:19.797565
2891	driver1	-1.31864	36.8352	0	2025-04-30 08:27:35.107537
2892	driver1	-1.31864	36.8352	0	2025-04-30 08:27:50.291652
2893	driver1	-1.31864	36.8352	0	2025-04-30 08:28:05.816806
2894	driver1	-1.31864	36.8352	0	2025-04-30 08:28:21.445624
2895	driver1	-1.31864	36.8352	0	2025-04-30 08:28:36.421611
2896	driver1	-1.31864	36.8352	0	2025-04-30 08:29:08.038907
2897	driver1	-1.31864	36.8352	0	2025-04-30 08:29:23.009981
2898	driver1	-1.31864	36.8352	0	2025-04-30 08:29:37.891295
2899	driver1	-1.31864	36.8352	0	2025-04-30 08:30:01.344264
2900	driver1	-1.31864	36.8352	0	2025-04-30 08:30:30.683723
2901	driver1	-1.31864	36.8352	0	2025-04-30 08:30:46.15609
2902	driver1	-1.31864	36.8352	0	2025-04-30 08:30:59.613238
2903	driver1	-1.31864	36.8352	0	2025-04-30 08:31:30.29264
2904	driver1	-1.31864	36.8352	0	2025-04-30 08:31:59.741391
2905	driver1	-1.31864	36.8352	0	2025-04-30 08:32:15.087233
2906	driver1	-1.31864	36.8352	0	2025-04-30 08:32:30.948076
2907	driver1	-1.31864	36.8352	0	2025-04-30 08:32:44.759744
2908	driver1	-1.31864	36.8352	0	2025-04-30 08:32:58.622717
2909	driver1	-1.31864	36.8352	0	2025-04-30 08:33:41.639755
2910	driver1	-1.31864	36.8352	0	2025-04-30 08:33:57.018892
2911	driver1	-1.31864	36.8352	0	2025-04-30 08:34:11.436104
2912	driver1	-1.31864	36.8352	0	2025-04-30 08:35:02.955862
2913	driver1	-1.31864	36.8352	0	2025-04-30 08:35:48.415003
2914	driver1	-1.31864	36.8352	0	2025-04-30 08:36:05.686136
2915	driver1	-1.31864	36.8352	0	2025-04-30 08:36:32.65146
2916	driver1	-1.31864	36.8352	0	2025-04-30 08:37:08.891016
2917	driver1	-1.31864	36.8352	0	2025-04-30 08:37:19.215557
2918	driver1	-1.31864	36.8352	0	2025-04-30 08:37:33.683987
2919	driver1	-1.31864	36.8352	0	2025-04-30 08:37:49.325827
2920	driver1	-1.31864	36.8352	0	2025-04-30 08:38:04.73555
2921	driver1	-1.31864	36.8352	0	2025-04-30 08:38:17.638041
2922	driver1	-1.31864	36.8352	0	2025-04-30 08:38:34.569223
2923	driver1	-1.31864	36.8352	0	2025-04-30 08:38:47.678073
2924	driver1	-1.31864	36.8352	0	2025-04-30 08:39:01.064978
2925	driver1	-1.31864	36.8352	0	2025-04-30 08:39:33.795854
2926	driver1	-1.31864	36.8352	0	2025-04-30 08:39:47.614342
2927	driver1	-1.31864	36.8352	0	2025-04-30 08:40:02.779823
2928	driver1	-1.31864	36.8352	0	2025-04-30 08:40:17.889025
2929	driver1	-1.31864	36.8352	0	2025-04-30 08:40:32.650037
2930	driver1	-1.31864	36.8352	0	2025-04-30 08:40:48.272743
2931	driver1	-1.31864	36.8352	0	2025-04-30 08:41:02.885655
2932	driver1	-1.31864	36.8352	0	2025-04-30 08:41:18.300559
2933	driver1	-1.31864	36.8352	0	2025-04-30 08:42:03.045718
2934	driver1	-1.31864	36.8352	0	2025-04-30 08:42:16.822091
2935	driver1	-1.31864	36.8352	0	2025-04-30 08:42:45.769876
2936	driver1	-1.31864	36.8352	0	2025-04-30 08:43:01.577331
2937	driver1	-1.31864	36.8352	0	2025-04-30 08:43:13.797467
2938	driver1	-1.31864	36.8352	0	2025-04-30 08:43:28.663911
2939	driver1	-1.31864	36.8352	0	2025-04-30 08:43:42.817918
2940	driver1	-1.31864	36.8352	0	2025-04-30 08:43:59.613285
2970	driver1	-1.31864	36.8352	0	2025-04-30 17:29:16.190028
2971	driver1	-1.31864	36.8352	0	2025-04-30 17:29:33.413303
2972	driver1	-1.31864	36.8352	0	2025-04-30 17:29:46.425212
2973	driver1	-1.31864	36.8352	0	2025-04-30 17:30:12.516183
2974	driver1	-1.31864	36.8352	0	2025-04-30 17:30:25.427175
2975	driver1	-1.31864	36.8352	0	2025-04-30 17:30:38.510208
2976	driver1	-1.31864	36.8352	0	2025-04-30 17:30:51.438835
2977	driver1	-1.31864	36.8352	0	2025-04-30 17:31:04.420611
2978	driver1	-1.31864	36.8352	0	2025-04-30 17:31:17.491278
2979	driver1	-1.31864	36.8352	0	2025-04-30 17:31:30.443391
2980	driver1	-1.31864	36.8352	0	2025-04-30 17:31:43.577478
2981	driver1	-1.31864	36.8352	0	2025-04-30 17:31:56.422341
2982	driver1	-1.31864	36.8352	0	2025-04-30 17:32:09.393042
2983	driver1	-1.31864	36.8352	0	2025-04-30 17:32:22.419719
2984	driver1	-1.31864	36.8352	0	2025-04-30 17:32:46.617311
2985	driver1	-1.31864	36.8352	0	2025-04-30 17:32:59.518748
2986	driver1	-1.31864	36.8352	0	2025-04-30 17:33:39.459377
2987	driver1	-1.31864	36.8352	0	2025-04-30 17:33:52.664817
2988	driver1	-1.31864	36.8352	0	2025-04-30 17:34:04.456025
2989	driver1	-1.31864	36.8352	0	2025-04-30 17:34:15.781953
2990	driver1	-1.31864	36.8352	0	2025-04-30 17:54:26.014764
2991	driver1	-1.31864	36.8352	0	2025-04-30 17:58:41.984772
2992	driver1	-1.31864	36.8352	0	2025-04-30 17:58:47.495267
2993	driver1	-1.31864	36.8352	0	2025-04-30 18:14:40.396856
2994	driver1	-1.31864	36.8352	0	2025-04-30 18:14:44.355844
2995	driver1	-1.31864	36.8352	0	2025-04-30 18:17:56.255997
\.


--
-- Data for Name: maintenance; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.maintenance (maintenanceid, vehicleid, maintenancedate, maintenancetype, description, cost, status) FROM stdin;
5	3	2025-05-07 00:00:00	Service	asdasd	20000	PENDING
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.notifications (id, driver_username, title, message, icon, color, created_at, read_at) FROM stdin;
1	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-23 12:52:01.442032+03	\N
2	driver1	Status Updated	Your status has been changed from BREAK to OFFLINE	pi pi-check-circle	success	2025-05-23 12:52:05.992677+03	\N
3	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-23 12:52:16.66239+03	\N
4	driver1	Status Updated	Your status has been changed from ACTIVE to OFFLINE	pi pi-check-circle	success	2025-05-23 12:52:18.049974+03	\N
5	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-23 12:52:24.923438+03	\N
6	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-23 12:52:26.144484+03	\N
7	driver1	Status Updated	Your status has been changed from BREAK to OFFLINE	pi pi-check-circle	success	2025-05-23 12:52:27.287575+03	\N
8	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-23 12:52:29.884835+03	\N
9	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-23 12:52:31.056873+03	\N
10	driver1	Status Updated	Your status has been changed from BREAK to ACTIVE	pi pi-check-circle	success	2025-05-23 12:52:32.351331+03	\N
11	driver1	Status Updated	Your status has been changed from ACTIVE to OFFLINE	pi pi-check-circle	success	2025-05-23 12:52:33.519759+03	\N
12	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-23 12:52:37.935759+03	\N
13	driver1	Status Updated	Your status has been changed from ACTIVE to OFFLINE	pi pi-check-circle	success	2025-05-23 12:52:39.432077+03	\N
14	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-23 12:52:42.113628+03	\N
15	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-23 12:52:42.915196+03	\N
16	driver1	Status Updated	Your status has been changed from BREAK to OFFLINE	pi pi-check-circle	success	2025-05-23 12:52:52.020689+03	\N
17	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-23 12:53:08.758897+03	\N
18	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-23 13:11:19.625778+03	\N
19	driver1	Status Updated	Your status has been changed from BREAK to ACTIVE	pi pi-check-circle	success	2025-05-23 13:12:26.20025+03	\N
20	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-23 13:38:52.398377+03	\N
21	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-27 18:39:38.444748+03	\N
22	driver1	Status Updated	Your status has been changed from BREAK to OFFLINE	pi pi-check-circle	success	2025-05-27 18:39:39.901897+03	\N
23	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-27 18:39:43.06705+03	\N
24	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-28 19:49:54.982328+03	\N
25	driver1	Status Updated	Your status has been changed from BREAK to OFFLINE	pi pi-check-circle	success	2025-05-28 19:49:57.158354+03	\N
26	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-28 19:50:00.299168+03	\N
27	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-28 19:50:08.293735+03	\N
28	driver1	Status Updated	Your status has been changed from BREAK to OFFLINE	pi pi-check-circle	success	2025-05-28 19:50:09.412361+03	\N
29	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-28 19:50:10.584496+03	\N
30	driver1	Status Updated	Your status has been changed from ACTIVE to OFFLINE	pi pi-check-circle	success	2025-05-29 04:55:37.238412+03	\N
31	driver1	Status Updated	Your status has been changed from ACTIVE to BREAK	pi pi-check-circle	success	2025-05-29 05:25:45.933158+03	\N
32	driver1	Status Updated	Your status has been changed from BREAK to OFFLINE	pi pi-check-circle	success	2025-05-29 05:25:47.278214+03	\N
33	driver1	Status Updated	Your status has been changed from OFFLINE to ACTIVE	pi pi-check-circle	success	2025-05-29 05:26:12.095736+03	\N
34	driver1	Status Updated	Your status has been changed from ACTIVE to OFFLINE	pi pi-check-circle	success	2025-05-29 05:26:13.665381+03	\N
\.


--
-- Data for Name: route_assignments; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.route_assignments (id, vehicle_id, driver_id, route_id, assignment_date, status, created_at) FROM stdin;
1	13	15	8	2025-04-29	scheduled	2025-04-28 09:52:49.645495+03
2	19	15	8	2025-04-29	scheduled	2025-04-28 09:52:49.645495+03
3	18	14	8	2025-04-29	scheduled	2025-04-28 09:52:49.645495+03
4	16	13	8	2025-04-29	scheduled	2025-04-28 09:52:49.645495+03
5	15	12	8	2025-04-29	scheduled	2025-04-28 09:52:49.645495+03
6	12	11	7	2025-04-29	scheduled	2025-04-28 09:52:49.645495+03
7	11	10	7	2025-04-29	scheduled	2025-04-28 09:52:49.645495+03
8	13	15	8	2025-04-30	scheduled	2025-04-28 09:52:49.645495+03
9	19	15	8	2025-04-30	scheduled	2025-04-28 09:52:49.645495+03
10	18	14	8	2025-04-30	scheduled	2025-04-28 09:52:49.645495+03
11	16	13	7	2025-04-30	scheduled	2025-04-28 09:52:49.645495+03
12	15	12	7	2025-04-30	scheduled	2025-04-28 09:52:49.645495+03
13	12	11	7	2025-04-30	scheduled	2025-04-28 09:52:49.645495+03
14	11	10	6	2025-04-30	scheduled	2025-04-28 09:52:49.645495+03
15	6	8	8	2025-05-01	scheduled	2025-04-28 09:52:49.645495+03
16	13	15	8	2025-05-01	scheduled	2025-04-28 09:52:49.645495+03
17	19	15	8	2025-05-01	scheduled	2025-04-28 09:52:49.645495+03
18	18	14	8	2025-05-01	scheduled	2025-04-28 09:52:49.645495+03
19	16	13	8	2025-05-01	scheduled	2025-04-28 09:52:49.645495+03
20	15	12	7	2025-05-01	scheduled	2025-04-28 09:52:49.645495+03
21	12	11	7	2025-05-01	scheduled	2025-04-28 09:52:49.645495+03
22	11	10	7	2025-05-01	scheduled	2025-04-28 09:52:49.645495+03
23	6	8	8	2025-05-02	scheduled	2025-04-28 09:52:49.645495+03
24	13	15	8	2025-05-02	scheduled	2025-04-28 09:52:49.645495+03
25	19	15	8	2025-05-02	scheduled	2025-04-28 09:52:49.645495+03
26	18	14	8	2025-05-02	scheduled	2025-04-28 09:52:49.645495+03
27	16	13	7	2025-05-02	scheduled	2025-04-28 09:52:49.645495+03
28	15	12	7	2025-05-02	scheduled	2025-04-28 09:52:49.645495+03
29	12	11	7	2025-05-02	scheduled	2025-04-28 09:52:49.645495+03
30	11	10	6	2025-05-02	scheduled	2025-04-28 09:52:49.645495+03
31	6	8	8	2025-05-03	scheduled	2025-04-28 09:52:49.645495+03
32	13	15	8	2025-05-03	scheduled	2025-04-28 09:52:49.645495+03
33	19	15	8	2025-05-03	scheduled	2025-04-28 09:52:49.645495+03
34	18	14	8	2025-05-03	scheduled	2025-04-28 09:52:49.645495+03
35	16	13	7	2025-05-03	scheduled	2025-04-28 09:52:49.645495+03
36	15	12	7	2025-05-03	scheduled	2025-04-28 09:52:49.645495+03
37	12	11	7	2025-05-03	scheduled	2025-04-28 09:52:49.645495+03
38	11	10	6	2025-05-03	scheduled	2025-04-28 09:52:49.645495+03
39	6	8	8	2025-05-04	scheduled	2025-04-28 09:52:49.645495+03
40	13	15	8	2025-05-04	scheduled	2025-04-28 09:52:49.645495+03
41	19	15	8	2025-05-04	scheduled	2025-04-28 09:52:49.645495+03
42	18	14	8	2025-05-04	scheduled	2025-04-28 09:52:49.645495+03
43	16	13	8	2025-05-04	scheduled	2025-04-28 09:52:49.645495+03
44	15	12	7	2025-05-04	scheduled	2025-04-28 09:52:49.645495+03
45	12	11	7	2025-05-04	scheduled	2025-04-28 09:52:49.645495+03
46	11	10	7	2025-05-04	scheduled	2025-04-28 09:52:49.645495+03
47	6	8	8	2025-05-05	scheduled	2025-04-30 15:30:40.195858+03
48	6	8	8	2025-05-06	scheduled	2025-04-30 15:30:40.195858+03
49	6	8	8	2025-05-07	scheduled	2025-05-07 07:48:11.358196+03
50	6	8	8	2025-05-08	scheduled	2025-05-07 07:48:11.358196+03
51	1	4	7	2025-05-08	scheduled	2025-05-07 07:48:11.358196+03
52	6	8	8	2025-05-09	scheduled	2025-05-07 07:48:11.358196+03
53	1	4	7	2025-05-09	scheduled	2025-05-07 07:48:11.358196+03
54	6	8	8	2025-05-10	scheduled	2025-05-07 07:48:11.358196+03
55	1	4	7	2025-05-10	scheduled	2025-05-07 07:48:11.358196+03
56	6	8	8	2025-05-11	scheduled	2025-05-07 07:48:11.358196+03
57	1	4	7	2025-05-11	scheduled	2025-05-07 07:48:11.358196+03
58	6	8	8	2025-05-12	scheduled	2025-05-07 07:48:11.358196+03
59	1	4	7	2025-05-12	scheduled	2025-05-07 07:48:11.358196+03
60	6	8	8	2025-05-13	scheduled	2025-05-07 07:48:11.358196+03
61	1	4	7	2025-05-13	scheduled	2025-05-07 07:48:11.358196+03
62	18	7	8	2025-05-11	scheduled	2025-05-09 15:02:04.139118+03
63	18	7	8	2025-05-12	scheduled	2025-05-09 15:02:04.139118+03
64	18	7	8	2025-05-13	scheduled	2025-05-09 15:02:04.139118+03
65	6	8	8	2025-05-14	scheduled	2025-05-09 15:02:04.139118+03
66	18	7	7	2025-05-14	scheduled	2025-05-09 15:02:04.139118+03
67	6	8	8	2025-05-15	scheduled	2025-05-09 15:02:04.139118+03
68	18	7	7	2025-05-15	scheduled	2025-05-09 15:02:04.139118+03
69	18	2	9	2025-06-10	scheduled	2025-06-04 00:49:24.959302+03
70	1	2	9	2025-06-05	scheduled	2025-06-04 08:06:46.378999+03
71	1	2	9	2025-06-06	scheduled	2025-06-04 08:06:46.378999+03
72	1	2	9	2025-06-07	scheduled	2025-06-04 08:06:46.378999+03
73	1	2	9	2025-06-08	scheduled	2025-06-04 08:06:46.378999+03
74	1	2	9	2025-06-09	scheduled	2025-06-04 08:06:46.378999+03
75	1	2	9	2025-06-10	scheduled	2025-06-04 08:06:46.378999+03
76	1	2	9	2025-06-15	scheduled	2025-06-13 20:54:55.265363+03
77	1	2	9	2025-06-16	scheduled	2025-06-13 20:54:55.265363+03
78	1	2	9	2025-06-17	scheduled	2025-06-13 20:54:55.265363+03
79	1	2	9	2025-06-18	scheduled	2025-06-13 20:54:55.265363+03
80	1	2	9	2025-06-19	scheduled	2025-06-13 20:54:55.265363+03
\.


--
-- Data for Name: route_kpis; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.route_kpis (id, route_id, metric_at, headway_target_s, on_time_perf_pct, avg_speed_kmh, load_factor_pct, extra_metrics, updated_at) FROM stdin;
1	4	2025-04-20 14:19:51.866282+03	900	82.50	18.75	85.2	{"peak_hour_delay_min": 12, "fuel_efficiency_km_l": 3.8, "passenger_satisfaction": 3.7}	2025-04-27 14:19:51.866282+03
2	4	2025-04-21 14:19:51.866282+03	900	79.30	17.8	87.6	{"peak_hour_delay_min": 15, "fuel_efficiency_km_l": 3.7, "passenger_satisfaction": 3.5}	2025-04-27 14:19:51.866282+03
3	4	2025-04-22 14:19:51.866282+03	900	85.10	19.2	82.4	{"peak_hour_delay_min": 10, "fuel_efficiency_km_l": 3.9, "passenger_satisfaction": 3.8}	2025-04-27 14:19:51.866282+03
4	4	2025-04-23 14:19:51.866282+03	900	81.70	18.5	84.9	{"peak_hour_delay_min": 13, "fuel_efficiency_km_l": 3.8, "passenger_satisfaction": 3.6}	2025-04-27 14:19:51.866282+03
5	4	2025-04-24 14:19:51.866282+03	900	83.20	18.9	86.1	{"peak_hour_delay_min": 11, "fuel_efficiency_km_l": 3.9, "passenger_satisfaction": 3.7}	2025-04-27 14:19:51.866282+03
6	4	2025-04-25 14:19:51.866282+03	900	80.60	17.6	88.3	{"peak_hour_delay_min": 14, "fuel_efficiency_km_l": 3.7, "passenger_satisfaction": 3.6}	2025-04-27 14:19:51.866282+03
7	4	2025-04-26 14:19:51.866282+03	900	84.40	19.1	83.7	{"peak_hour_delay_min": 10, "fuel_efficiency_km_l": 3.8, "passenger_satisfaction": 3.8}	2025-04-27 14:19:51.866282+03
8	5	2025-04-20 14:19:51.892534+03	1200	78.40	16.2	89.5	{"peak_hour_delay_min": 18, "fuel_efficiency_km_l": 3.5, "passenger_satisfaction": 3.4}	2025-04-27 14:19:51.892534+03
9	5	2025-04-21 14:19:51.892534+03	1200	75.60	15.8	91.2	{"peak_hour_delay_min": 20, "fuel_efficiency_km_l": 3.4, "passenger_satisfaction": 3.3}	2025-04-27 14:19:51.892534+03
10	5	2025-04-22 14:19:51.892534+03	1200	79.80	16.7	88.3	{"peak_hour_delay_min": 17, "fuel_efficiency_km_l": 3.6, "passenger_satisfaction": 3.5}	2025-04-27 14:19:51.892534+03
11	5	2025-04-23 14:19:51.892534+03	1200	77.20	16.1	90.4	{"peak_hour_delay_min": 19, "fuel_efficiency_km_l": 3.5, "passenger_satisfaction": 3.3}	2025-04-27 14:19:51.892534+03
12	5	2025-04-24 14:19:51.892534+03	1200	78.90	16.4	89.1	{"peak_hour_delay_min": 17, "fuel_efficiency_km_l": 3.6, "passenger_satisfaction": 3.4}	2025-04-27 14:19:51.892534+03
13	5	2025-04-25 14:19:51.892534+03	1200	76.50	15.9	92.3	{"peak_hour_delay_min": 21, "fuel_efficiency_km_l": 3.4, "passenger_satisfaction": 3.2}	2025-04-27 14:19:51.892534+03
14	5	2025-04-26 14:19:51.892534+03	1200	80.10	16.8	87.9	{"peak_hour_delay_min": 16, "fuel_efficiency_km_l": 3.7, "passenger_satisfaction": 3.6}	2025-04-27 14:19:51.892534+03
15	6	2025-04-20 14:19:51.895216+03	780	85.60	20.3	82.7	{"peak_hour_delay_min": 9, "fuel_efficiency_km_l": 4.0, "passenger_satisfaction": 3.9}	2025-04-27 14:19:51.895216+03
16	6	2025-04-21 14:19:51.895216+03	780	83.90	19.8	84.1	{"peak_hour_delay_min": 11, "fuel_efficiency_km_l": 3.9, "passenger_satisfaction": 3.8}	2025-04-27 14:19:51.895216+03
17	6	2025-04-22 14:19:51.895216+03	780	87.20	20.9	81.5	{"peak_hour_delay_min": 8, "fuel_efficiency_km_l": 4.1, "passenger_satisfaction": 4.0}	2025-04-27 14:19:51.895216+03
18	6	2025-04-23 14:19:51.895216+03	780	84.70	20.1	83.4	{"peak_hour_delay_min": 10, "fuel_efficiency_km_l": 4.0, "passenger_satisfaction": 3.9}	2025-04-27 14:19:51.895216+03
19	6	2025-04-24 14:19:51.895216+03	780	86.10	20.5	82.2	{"peak_hour_delay_min": 9, "fuel_efficiency_km_l": 4.0, "passenger_satisfaction": 3.9}	2025-04-27 14:19:51.895216+03
20	6	2025-04-25 14:19:51.895216+03	780	84.20	19.7	84.8	{"peak_hour_delay_min": 11, "fuel_efficiency_km_l": 3.9, "passenger_satisfaction": 3.8}	2025-04-27 14:19:51.895216+03
21	6	2025-04-26 14:19:51.895216+03	780	87.50	21	81.1	{"peak_hour_delay_min": 7, "fuel_efficiency_km_l": 4.1, "passenger_satisfaction": 4.0}	2025-04-27 14:19:51.895216+03
22	7	2025-04-20 14:19:51.89776+03	1500	75.20	22.4	78.3	{"peak_hour_delay_min": 22, "fuel_efficiency_km_l": 3.3, "passenger_satisfaction": 3.2}	2025-04-27 14:19:51.89776+03
23	7	2025-04-21 14:19:51.89776+03	1500	72.60	21.8	80.7	{"peak_hour_delay_min": 25, "fuel_efficiency_km_l": 3.2, "passenger_satisfaction": 3.1}	2025-04-27 14:19:51.89776+03
24	7	2025-04-22 14:19:51.89776+03	1500	76.90	22.9	77.5	{"peak_hour_delay_min": 20, "fuel_efficiency_km_l": 3.4, "passenger_satisfaction": 3.3}	2025-04-27 14:19:51.89776+03
25	7	2025-04-23 14:19:51.89776+03	1500	74.10	22.3	79.4	{"peak_hour_delay_min": 23, "fuel_efficiency_km_l": 3.3, "passenger_satisfaction": 3.2}	2025-04-27 14:19:51.89776+03
26	7	2025-04-24 14:19:51.89776+03	1500	75.80	22.6	78.1	{"peak_hour_delay_min": 21, "fuel_efficiency_km_l": 3.4, "passenger_satisfaction": 3.3}	2025-04-27 14:19:51.89776+03
27	7	2025-04-25 14:19:51.89776+03	1500	73.50	21.9	81.6	{"peak_hour_delay_min": 24, "fuel_efficiency_km_l": 3.2, "passenger_satisfaction": 3.0}	2025-04-27 14:19:51.89776+03
28	7	2025-04-26 14:19:51.89776+03	1500	77.30	23.1	76.8	{"peak_hour_delay_min": 19, "fuel_efficiency_km_l": 3.5, "passenger_satisfaction": 3.4}	2025-04-27 14:19:51.89776+03
29	8	2025-04-20 14:19:51.900053+03	1020	81.30	17.6	86.4	{"peak_hour_delay_min": 14, "fuel_efficiency_km_l": 3.7, "passenger_satisfaction": 3.6}	2025-04-27 14:19:51.900053+03
30	8	2025-04-21 14:19:51.900053+03	1020	79.70	17.1	88.2	{"peak_hour_delay_min": 16, "fuel_efficiency_km_l": 3.6, "passenger_satisfaction": 3.5}	2025-04-27 14:19:51.900053+03
31	8	2025-04-22 14:19:51.900053+03	1020	82.90	18.2	85.3	{"peak_hour_delay_min": 13, "fuel_efficiency_km_l": 3.8, "passenger_satisfaction": 3.7}	2025-04-27 14:19:51.900053+03
32	8	2025-04-23 14:19:51.900053+03	1020	80.50	17.5	87.1	{"peak_hour_delay_min": 15, "fuel_efficiency_km_l": 3.7, "passenger_satisfaction": 3.6}	2025-04-27 14:19:51.900053+03
33	8	2025-04-24 14:19:51.900053+03	1020	81.80	17.9	86.2	{"peak_hour_delay_min": 14, "fuel_efficiency_km_l": 3.7, "passenger_satisfaction": 3.6}	2025-04-27 14:19:51.900053+03
34	8	2025-04-25 14:19:51.900053+03	1020	80.10	17.3	88.9	{"peak_hour_delay_min": 16, "fuel_efficiency_km_l": 3.6, "passenger_satisfaction": 3.5}	2025-04-27 14:19:51.900053+03
35	8	2025-04-26 14:19:51.900053+03	1020	83.20	18.4	85	{"peak_hour_delay_min": 12, "fuel_efficiency_km_l": 3.8, "passenger_satisfaction": 3.7}	2025-04-27 14:19:51.900053+03
36	9	2025-06-01 14:00:00+03	900	82.50	18.3	84.2	{"peak_hour_delay_min": 13, "fuel_efficiency_km_l": 3.8, "passenger_satisfaction": 3.6}	2025-06-01 20:00:00+03
37	9	2025-06-02 14:00:00+03	900	79.40	17.9	85	{"peak_hour_delay_min": 15, "fuel_efficiency_km_l": 3.7, "passenger_satisfaction": 3.5}	2025-06-02 20:00:00+03
38	9	2025-06-03 14:00:00+03	900	83.70	18.7	83.9	{"peak_hour_delay_min": 12, "fuel_efficiency_km_l": 3.9, "passenger_satisfaction": 3.7}	2025-06-03 20:00:00+03
\.


--
-- Data for Name: route_time_patterns; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.route_time_patterns (id, route_id, stage, time_slot, demand_factor, vehicle_requirement) FROM stdin;
\.


--
-- Data for Name: route_timetables; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.route_timetables (id, route_id, service_date, departure_times, created_at) FROM stdin;
1	8	2025-04-27	{}	2025-04-27 19:21:58.069909+03
2	7	2025-04-27	{}	2025-04-27 19:21:58.069909+03
3	6	2025-04-27	{}	2025-04-27 19:21:58.069909+03
4	5	2025-04-27	{}	2025-04-27 19:21:58.069909+03
5	4	2025-04-27	{}	2025-04-27 19:21:58.069909+03
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.routes (id, name, origin_stage, destination_stage, stages, operational_hours, created_at) FROM stdin;
4	CBD - Embakasi	Nairobi CBD	Embakasi	[{"name": "Nairobi CBD", "location": "Point(-1.2867, 36.8196)"}, {"name": "Muthurwa", "location": "Point(-1.2904, 36.8333)"}, {"name": "Gikomba", "location": "Point(-1.2850, 36.8400)"}, {"name": "Buruburu", "location": "Point(-1.2877, 36.8787)"}, {"name": "Donholm", "location": "Point(-1.2995, 36.8897)"}, {"name": "Pipeline", "location": "Point(-1.3159, 36.9048)"}, {"name": "Fedha", "location": "Point(-1.3249, 36.9182)"}, {"name": "Embakasi", "location": "Point(-1.3310, 36.9230)"}]	["2000-01-01 05:30:00","2000-01-01 22:30:00")	2025-04-27 12:52:24.0725+03
5	CBD - Kayole	Nairobi CBD	Kayole	[{"name": "Nairobi CBD", "location": "Point(-1.2867, 36.8196)"}, {"name": "Muthurwa", "location": "Point(-1.2904, 36.8333)"}, {"name": "Gikomba", "location": "Point(-1.2850, 36.8400)"}, {"name": "Buruburu", "location": "Point(-1.2877, 36.8787)"}, {"name": "Donholm", "location": "Point(-1.2995, 36.8897)"}, {"name": "Saika", "location": "Point(-1.2848, 36.9178)"}, {"name": "Kayole", "location": "Point(-1.2627, 36.9233)"}]	["2000-01-01 05:30:00","2000-01-01 22:30:00")	2025-04-27 12:52:24.081185+03
6	CBD - Umoja	Nairobi CBD	Umoja	[{"name": "Nairobi CBD", "location": "Point(-1.2867, 36.8196)"}, {"name": "Muthurwa", "location": "Point(-1.2904, 36.8333)"}, {"name": "Gikomba", "location": "Point(-1.2850, 36.8400)"}, {"name": "Buruburu", "location": "Point(-1.2877, 36.8787)"}, {"name": "Donholm", "location": "Point(-1.2995, 36.8897)"}, {"name": "Umoja I", "location": "Point(-1.2812, 36.8978)"}, {"name": "Umoja Innercore", "location": "Point(-1.2766, 36.9025)"}]	["2000-01-01 05:30:00","2000-01-01 22:30:00")	2025-04-27 12:52:24.082943+03
7	CBD - Utawala	Nairobi CBD	Utawala	[{"name": "Nairobi CBD", "location": "Point(-1.2867, 36.8196)"}, {"name": "Muthurwa", "location": "Point(-1.2904, 36.8333)"}, {"name": "Gikomba", "location": "Point(-1.2850, 36.8400)"}, {"name": "Buruburu", "location": "Point(-1.2877, 36.8787)"}, {"name": "Donholm", "location": "Point(-1.2995, 36.8897)"}, {"name": "Pipeline", "location": "Point(-1.3159, 36.9048)"}, {"name": "Fedha", "location": "Point(-1.3249, 36.9182)"}, {"name": "Embakasi", "location": "Point(-1.3310, 36.9230)"}, {"name": "Airport North Road", "location": "Point(-1.3267, 36.9361)"}, {"name": "Utawala", "location": "Point(-1.3051, 36.9725)"}]	["2000-01-01 05:30:00","2000-01-01 22:30:00")	2025-04-27 12:52:24.085471+03
8	CBD - Komarock	Nairobi CBD	Komarock	[{"name": "Nairobi CBD", "location": "Point(-1.2867, 36.8196)"}, {"name": "Muthurwa", "location": "Point(-1.2904, 36.8333)"}, {"name": "Gikomba", "location": "Point(-1.2850, 36.8400)"}, {"name": "Buruburu", "location": "Point(-1.2877, 36.8787)"}, {"name": "Donholm", "location": "Point(-1.2995, 36.8897)"}, {"name": "Kariobangi South", "location": "Point(-1.2676, 36.8935)"}, {"name": "Komarock", "location": "Point(-1.2635, 36.9097)"}]	["2000-01-01 05:30:00","2000-01-01 22:30:00")	2025-04-27 12:52:24.087513+03
9	CBD-Fedha	Fedha	CBD	[{"name": "CBD", "stageId": 0, "latitude": 0.0, "sequence": 0, "longitude": 0.0, "distanceMeters": 0.0, "expectedTravelTimeSeconds": 0}, {"name": "Fedha Estate", "stageId": 0, "latitude": 0.0, "sequence": 0, "longitude": 0.0, "distanceMeters": 0.0, "expectedTravelTimeSeconds": 0}, {"name": "New", "stageId": 0, "latitude": 0.0, "sequence": 0, "longitude": 0.0, "distanceMeters": 0.0, "expectedTravelTimeSeconds": 0}]	["2000-01-01 05:30:00","2000-01-01 22:30:00")	2025-06-02 10:37:51.03276+03
\.


--
-- Data for Name: trip_records; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.trip_records (id, driver_username, trip_date, passenger_count, route_id, vehicle_id, status, created_at) FROM stdin;
\.


--
-- Data for Name: trips; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.trips (trip_id, driver_id, fare, route_id, start_time, end_time, driver_username, status, vehicle_id) FROM stdin;
25460	9	225.00	6	2025-03-30 19:29:47.807946	2025-03-30 19:51:47.807946	\N	completed	11
25461	8	495.00	5	2025-03-30 13:04:47.807946	2025-03-30 13:47:47.807946	\N	completed	3
25462	7	495.00	6	2025-03-30 10:43:47.807946	2025-03-30 11:30:47.807946	\N	completed	34
25463	8	340.00	5	2025-03-30 22:53:47.807946	2025-03-30 23:24:47.807946	\N	completed	8
25464	16	525.00	4	2025-03-30 07:13:47.807946	2025-03-30 07:33:47.807946	\N	completed	11
25465	15	420.00	8	2025-03-30 15:07:47.807946	2025-03-30 15:51:47.807946	\N	completed	36
25466	8	600.00	9	2025-03-30 21:48:47.807946	2025-03-30 22:31:47.807946	\N	completed	1
25467	28	375.00	7	2025-03-30 14:17:47.807946	2025-03-30 14:37:47.807946	\N	completed	6
25468	10	480.00	6	2025-03-30 06:11:47.807946	2025-03-30 06:44:47.807946	\N	completed	34
25469	30	420.00	6	2025-03-30 14:33:47.807946	2025-03-30 15:15:47.807946	\N	completed	6
25470	10	390.00	5	2025-03-30 13:24:47.807946	2025-03-30 13:47:47.807946	\N	completed	9
25471	9	775.00	9	2025-03-30 08:51:47.807946	2025-03-30 09:16:47.807946	\N	completed	32
25472	14	750.00	9	2025-03-30 17:16:47.807946	2025-03-30 17:47:47.807946	\N	completed	8
25473	14	850.00	8	2025-03-30 08:13:47.807946	2025-03-30 08:57:47.807946	\N	completed	3
25474	28	510.00	7	2025-03-30 10:16:47.807946	2025-03-30 10:55:47.807946	\N	completed	3
25475	9	575.00	9	2025-03-30 07:26:47.807946	2025-03-30 08:14:47.807946	\N	completed	36
25476	2	500.00	4	2025-03-30 05:13:47.807946	2025-03-30 05:55:47.807946	\N	completed	8
25477	10	480.00	4	2025-03-30 13:13:47.807946	2025-03-30 13:55:47.807946	\N	completed	32
25478	28	340.00	4	2025-03-30 21:13:47.807946	2025-03-30 21:44:47.807946	\N	completed	8
25479	15	450.00	9	2025-03-30 12:00:47.807946	2025-03-30 12:36:47.807946	\N	completed	10
25480	7	495.00	6	2025-03-31 09:20:47.807946	2025-03-31 09:51:47.807946	\N	completed	32
25481	2	525.00	4	2025-03-31 18:53:47.807946	2025-03-31 19:21:47.807946	\N	completed	32
25482	9	480.00	4	2025-03-31 20:45:47.807946	2025-03-31 21:12:47.807946	\N	completed	10
25483	11	600.00	6	2025-03-31 22:14:47.807946	2025-03-31 22:59:47.807946	\N	completed	36
25484	16	625.00	4	2025-03-31 17:22:47.807946	2025-03-31 17:42:47.807946	\N	completed	32
25485	7	255.00	4	2025-03-31 19:10:47.807946	2025-03-31 19:51:47.807946	\N	completed	34
25486	7	950.00	7	2025-03-31 18:19:47.807946	2025-03-31 19:00:47.807946	\N	completed	6
25487	12	975.00	8	2025-03-31 08:36:47.807946	2025-03-31 09:02:47.807946	\N	completed	9
25488	16	520.00	4	2025-03-31 22:10:47.807946	2025-03-31 22:58:47.807946	\N	completed	3
25489	9	400.00	8	2025-03-31 05:53:47.807946	2025-03-31 06:15:47.807946	\N	completed	32
25490	28	525.00	8	2025-03-31 13:46:47.807946	2025-03-31 14:19:47.807946	\N	completed	10
25491	28	525.00	5	2025-03-31 12:36:47.807946	2025-03-31 13:03:47.807946	\N	completed	6
25492	16	500.00	5	2025-03-31 06:49:47.807946	2025-03-31 07:35:47.807946	\N	completed	1
25493	16	1025.00	9	2025-03-31 17:13:47.807946	2025-03-31 17:49:47.807946	\N	completed	11
25494	10	420.00	9	2025-03-31 10:47:47.807946	2025-03-31 11:12:47.807946	\N	completed	9
25495	15	300.00	6	2025-03-31 19:36:47.807946	2025-03-31 20:23:47.807946	\N	completed	1
25496	30	875.00	5	2025-03-31 17:20:47.807946	2025-03-31 17:52:47.807946	\N	completed	6
25497	14	380.00	8	2025-03-31 20:11:47.807946	2025-03-31 20:53:47.807946	\N	completed	3
25498	7	300.00	8	2025-03-31 12:44:47.807946	2025-03-31 13:22:47.807946	\N	completed	32
25499	11	825.00	9	2025-03-31 07:02:47.807946	2025-03-31 07:27:47.807946	\N	completed	36
25500	9	460.00	9	2025-03-31 22:22:47.807946	2025-03-31 22:52:47.807946	\N	completed	3
25501	16	270.00	6	2025-03-31 13:53:47.807946	2025-03-31 14:32:47.807946	\N	completed	1
25502	14	525.00	5	2025-03-31 14:12:47.807946	2025-03-31 14:49:47.807946	\N	completed	11
25503	14	420.00	5	2025-03-31 14:03:47.807946	2025-03-31 14:41:47.807946	\N	completed	11
25504	16	725.00	5	2025-03-31 18:52:47.807946	2025-03-31 19:20:47.807946	\N	completed	1
25505	30	460.00	4	2025-04-01 21:12:47.807946	2025-04-01 21:37:47.807946	\N	completed	1
25506	16	800.00	6	2025-04-01 17:20:47.807946	2025-04-01 17:49:47.807946	\N	completed	36
25507	30	285.00	4	2025-04-01 13:28:47.807946	2025-04-01 13:56:47.807946	\N	completed	3
25508	12	480.00	5	2025-04-01 11:24:47.807946	2025-04-01 11:44:47.807946	\N	completed	32
25509	14	750.00	7	2025-04-01 08:24:47.807946	2025-04-01 09:00:47.807946	\N	completed	9
25510	12	600.00	5	2025-04-01 17:40:47.807946	2025-04-01 18:20:47.807946	\N	completed	34
25511	10	345.00	4	2025-04-01 13:41:47.807946	2025-04-01 14:14:47.807946	\N	completed	6
25512	15	750.00	9	2025-04-01 07:13:47.807946	2025-04-01 07:52:47.807946	\N	completed	36
25513	12	315.00	7	2025-04-01 11:33:47.807946	2025-04-01 12:14:47.807946	\N	completed	1
25514	15	270.00	7	2025-04-01 14:46:47.807946	2025-04-01 15:08:47.807946	\N	completed	36
25515	9	285.00	7	2025-04-01 14:01:47.807946	2025-04-01 14:45:47.807946	\N	completed	3
25516	14	440.00	8	2025-04-01 20:03:47.807946	2025-04-01 20:41:47.807946	\N	completed	11
25517	16	480.00	7	2025-04-01 21:21:47.807946	2025-04-01 21:50:47.807946	\N	completed	11
25518	10	420.00	8	2025-04-01 15:45:47.807946	2025-04-01 16:28:47.807946	\N	completed	32
25519	10	725.00	7	2025-04-01 08:08:47.807946	2025-04-01 08:30:47.807946	\N	completed	32
25520	12	420.00	6	2025-04-01 13:38:47.807946	2025-04-01 14:28:47.807946	\N	completed	8
25521	10	495.00	7	2025-04-01 13:34:47.807946	2025-04-01 14:16:47.807946	\N	completed	36
25522	16	360.00	5	2025-04-01 06:56:47.807946	2025-04-01 07:18:47.807946	\N	completed	36
25523	2	440.00	7	2025-04-01 20:46:47.807946	2025-04-01 21:29:47.807946	\N	completed	34
25524	16	495.00	8	2025-04-01 10:52:47.807946	2025-04-01 11:33:47.807946	\N	completed	36
25525	8	380.00	7	2025-04-01 21:12:47.807946	2025-04-01 21:53:47.807946	\N	completed	11
25526	10	750.00	6	2025-04-02 08:23:47.807946	2025-04-02 08:52:47.807946	\N	completed	11
25527	7	750.00	9	2025-04-02 07:09:47.807946	2025-04-02 07:34:47.807946	\N	completed	34
25528	11	600.00	5	2025-04-02 17:21:47.807946	2025-04-02 18:11:47.807946	\N	completed	11
25529	16	460.00	5	2025-04-02 22:30:47.807946	2025-04-02 23:07:47.807946	\N	completed	9
25530	2	550.00	7	2025-04-02 18:54:47.807946	2025-04-02 19:42:47.807946	\N	completed	32
25531	28	435.00	5	2025-04-02 19:31:47.807946	2025-04-02 20:21:47.807946	\N	completed	8
25532	9	340.00	5	2025-04-02 05:49:47.807946	2025-04-02 06:29:47.807946	\N	completed	34
25533	16	380.00	8	2025-04-02 20:43:47.807946	2025-04-02 21:16:47.807946	\N	completed	32
25534	14	1025.00	4	2025-04-02 17:48:47.807946	2025-04-02 18:32:47.807946	\N	completed	32
25535	16	850.00	6	2025-04-02 18:25:47.807946	2025-04-02 19:06:47.807946	\N	completed	3
25536	10	1000.00	7	2025-04-02 08:24:47.807946	2025-04-02 08:56:47.807946	\N	completed	8
25537	12	875.00	7	2025-04-02 17:18:47.807946	2025-04-02 17:44:47.807946	\N	completed	10
25538	8	315.00	4	2025-04-02 12:06:47.807946	2025-04-02 12:52:47.807946	\N	completed	34
25539	16	1000.00	5	2025-04-02 18:40:47.807946	2025-04-02 19:04:47.807946	\N	completed	1
25540	14	420.00	4	2025-04-02 11:56:47.807946	2025-04-02 12:28:47.807946	\N	completed	1
25541	30	850.00	9	2025-04-02 16:27:47.807946	2025-04-02 17:10:47.807946	\N	completed	10
25542	11	480.00	6	2025-04-02 22:31:47.807946	2025-04-02 22:52:47.807946	\N	completed	1
25543	30	400.00	4	2025-04-02 06:41:47.807946	2025-04-02 07:19:47.807946	\N	completed	34
25544	9	420.00	5	2025-04-02 06:23:47.807946	2025-04-02 06:56:47.807946	\N	completed	34
25545	28	500.00	7	2025-04-02 06:08:47.807946	2025-04-02 06:47:47.807946	\N	completed	34
25546	15	800.00	5	2025-04-02 16:43:47.807946	2025-04-02 17:06:47.807946	\N	completed	8
25547	10	285.00	6	2025-04-02 15:15:47.807946	2025-04-02 15:53:47.807946	\N	completed	8
25548	2	465.00	4	2025-04-03 15:27:47.807946	2025-04-03 16:12:47.807946	\N	completed	11
25549	16	320.00	5	2025-04-03 22:14:47.807946	2025-04-03 22:46:47.807946	\N	completed	32
25550	28	460.00	7	2025-04-03 05:22:47.807946	2025-04-03 05:51:47.807946	\N	completed	36
25551	28	500.00	7	2025-04-03 20:42:47.807946	2025-04-03 21:12:47.807946	\N	completed	6
25552	8	375.00	9	2025-04-03 09:43:47.807946	2025-04-03 10:24:47.807946	\N	completed	32
25553	11	270.00	7	2025-04-03 19:27:47.807946	2025-04-03 20:12:47.807946	\N	completed	34
25554	7	420.00	6	2025-04-03 13:28:47.807946	2025-04-03 13:55:47.807946	\N	completed	3
25555	7	300.00	5	2025-04-03 14:14:47.807946	2025-04-03 14:43:47.807946	\N	completed	34
25556	12	345.00	4	2025-04-03 19:46:47.807946	2025-04-03 20:25:47.807946	\N	completed	6
25557	10	465.00	5	2025-04-03 11:40:47.807946	2025-04-03 12:14:47.807946	\N	completed	3
25558	8	600.00	9	2025-04-03 16:15:47.807946	2025-04-03 16:50:47.807946	\N	completed	36
25559	16	380.00	4	2025-04-03 20:19:47.807946	2025-04-03 21:03:47.807946	\N	completed	36
25560	15	390.00	9	2025-04-03 10:56:47.807946	2025-04-03 11:18:47.807946	\N	completed	8
25561	30	925.00	9	2025-04-03 18:18:47.807946	2025-04-03 18:45:47.807946	\N	completed	36
25562	12	260.00	6	2025-04-03 06:31:47.807946	2025-04-03 06:57:47.807946	\N	completed	11
25563	14	315.00	6	2025-04-03 10:16:47.807946	2025-04-03 10:44:47.807946	\N	completed	8
25564	8	340.00	9	2025-04-03 20:34:47.807946	2025-04-03 21:19:47.807946	\N	completed	10
25565	9	360.00	8	2025-04-03 14:35:47.807946	2025-04-03 15:08:47.807946	\N	completed	9
25566	2	315.00	7	2025-04-03 09:02:47.807946	2025-04-03 09:22:47.807946	\N	completed	34
25567	16	900.00	6	2025-04-03 07:02:47.807946	2025-04-03 07:34:47.807946	\N	completed	32
25568	12	825.00	4	2025-04-03 08:59:47.807946	2025-04-03 09:32:47.807946	\N	completed	9
25569	28	440.00	8	2025-04-03 21:04:47.807946	2025-04-03 21:53:47.807946	\N	completed	32
25570	8	340.00	7	2025-04-03 20:52:47.807946	2025-04-03 21:13:47.807946	\N	completed	36
25571	10	405.00	7	2025-04-03 11:42:47.807946	2025-04-03 12:11:47.807946	\N	completed	3
25572	28	460.00	5	2025-04-03 05:16:47.807946	2025-04-03 05:54:47.807946	\N	completed	10
25573	14	580.00	6	2025-04-03 21:37:47.807946	2025-04-03 22:19:47.807946	\N	completed	6
25574	11	390.00	6	2025-04-03 15:04:47.807946	2025-04-03 15:40:47.807946	\N	completed	3
25575	14	925.00	9	2025-04-04 17:58:47.807946	2025-04-04 18:27:47.807946	\N	completed	11
25576	12	650.00	4	2025-04-04 08:13:47.807946	2025-04-04 08:52:47.807946	\N	completed	9
25577	10	300.00	9	2025-04-04 10:20:47.807946	2025-04-04 11:01:47.807946	\N	completed	34
25578	12	315.00	7	2025-04-04 09:07:47.807946	2025-04-04 09:41:47.807946	\N	completed	8
25579	7	575.00	9	2025-04-04 18:45:47.807946	2025-04-04 19:22:47.807946	\N	completed	8
25580	15	650.00	4	2025-04-04 18:10:47.807946	2025-04-04 18:52:47.807946	\N	completed	1
25581	11	400.00	5	2025-04-04 20:11:47.807946	2025-04-04 20:57:47.807946	\N	completed	1
25582	28	525.00	4	2025-04-04 13:15:47.807946	2025-04-04 13:58:47.807946	\N	completed	10
25583	16	390.00	7	2025-04-04 09:43:47.807946	2025-04-04 10:29:47.807946	\N	completed	8
25584	10	340.00	6	2025-04-04 06:01:47.807946	2025-04-04 06:40:47.807946	\N	completed	9
25585	14	975.00	9	2025-04-04 16:22:47.807946	2025-04-04 16:54:47.807946	\N	completed	10
25586	9	550.00	6	2025-04-04 18:56:47.807946	2025-04-04 19:45:47.807946	\N	completed	36
25587	10	725.00	9	2025-04-04 16:32:47.807946	2025-04-04 17:07:47.807946	\N	completed	1
25588	2	975.00	9	2025-04-04 17:22:47.807946	2025-04-04 17:55:47.807946	\N	completed	32
25589	12	510.00	4	2025-04-04 10:34:47.807946	2025-04-04 11:04:47.807946	\N	completed	32
25590	14	360.00	9	2025-04-04 11:45:47.807946	2025-04-04 12:22:47.807946	\N	completed	9
25591	9	450.00	4	2025-04-04 12:04:47.807946	2025-04-04 12:34:47.807946	\N	completed	9
25592	16	800.00	9	2025-04-04 16:38:47.807946	2025-04-04 17:24:47.807946	\N	completed	6
25593	10	975.00	5	2025-04-04 07:03:47.807946	2025-04-04 07:33:47.807946	\N	completed	32
25594	10	440.00	6	2025-04-04 20:27:47.807946	2025-04-04 21:11:47.807946	\N	completed	8
25595	11	285.00	6	2025-04-05 13:27:47.807946	2025-04-05 13:58:47.807946	\N	completed	8
25596	12	315.00	7	2025-04-05 09:10:47.807946	2025-04-05 09:40:47.807946	\N	completed	9
25597	12	405.00	6	2025-04-05 12:22:47.807946	2025-04-05 13:01:47.807946	\N	completed	32
25598	10	390.00	8	2025-04-05 19:45:47.807946	2025-04-05 20:24:47.807946	\N	completed	6
25599	2	540.00	7	2025-04-05 20:58:47.807946	2025-04-05 21:20:47.807946	\N	completed	1
25600	12	380.00	7	2025-04-05 22:28:47.807946	2025-04-05 23:03:47.807946	\N	completed	8
25601	2	950.00	8	2025-04-05 18:46:47.807946	2025-04-05 19:07:47.807946	\N	completed	36
25602	16	495.00	6	2025-04-05 10:58:47.807946	2025-04-05 11:26:47.807946	\N	completed	36
25603	10	975.00	8	2025-04-05 17:43:47.807946	2025-04-05 18:24:47.807946	\N	completed	34
25604	8	480.00	5	2025-04-05 06:05:47.807946	2025-04-05 06:34:47.807946	\N	completed	10
25605	9	510.00	6	2025-04-05 15:30:47.807946	2025-04-05 16:08:47.807946	\N	completed	3
25606	2	375.00	5	2025-04-05 12:07:47.807946	2025-04-05 12:30:47.807946	\N	completed	1
25607	9	420.00	8	2025-04-05 12:52:47.807946	2025-04-05 13:30:47.807946	\N	completed	10
25608	2	450.00	8	2025-04-05 13:09:47.807946	2025-04-05 13:39:47.807946	\N	completed	6
25609	14	315.00	7	2025-04-05 19:58:47.807946	2025-04-05 20:23:47.807946	\N	completed	9
25610	8	495.00	9	2025-04-05 14:08:47.807946	2025-04-05 14:53:47.807946	\N	completed	1
25611	14	600.00	5	2025-04-05 21:58:47.807946	2025-04-05 22:18:47.807946	\N	completed	36
25612	14	600.00	9	2025-04-05 21:02:47.807946	2025-04-05 21:45:47.807946	\N	completed	3
25613	9	480.00	6	2025-04-05 22:57:47.807946	2025-04-05 23:19:47.807946	\N	completed	6
25614	10	390.00	9	2025-04-05 14:34:47.807946	2025-04-05 15:24:47.807946	\N	completed	3
25615	12	580.00	9	2025-04-05 20:27:47.807946	2025-04-05 21:05:47.807946	\N	completed	8
25616	2	390.00	4	2025-04-05 09:13:47.807946	2025-04-05 09:52:47.807946	\N	completed	34
25617	12	270.00	5	2025-04-05 13:09:47.807946	2025-04-05 13:39:47.807946	\N	completed	11
25618	30	405.00	8	2025-04-05 10:21:47.807946	2025-04-05 10:43:47.807946	\N	completed	6
25619	9	450.00	6	2025-04-05 13:43:47.807946	2025-04-05 14:20:47.807946	\N	completed	11
25620	2	600.00	4	2025-04-05 07:26:47.807946	2025-04-05 07:48:47.807946	\N	completed	36
25621	8	345.00	7	2025-04-06 09:34:47.807946	2025-04-06 09:55:47.807946	\N	completed	34
25622	8	625.00	6	2025-04-06 16:56:47.807946	2025-04-06 17:29:47.807946	\N	completed	6
25623	7	675.00	6	2025-04-06 18:09:47.807946	2025-04-06 18:29:47.807946	\N	completed	3
25624	11	750.00	5	2025-04-06 07:03:47.807946	2025-04-06 07:28:47.807946	\N	completed	32
25625	9	775.00	7	2025-04-06 17:56:47.807946	2025-04-06 18:29:47.807946	\N	completed	34
25626	30	700.00	5	2025-04-06 18:05:47.807946	2025-04-06 18:42:47.807946	\N	completed	8
25627	11	435.00	4	2025-04-06 19:13:47.807946	2025-04-06 19:58:47.807946	\N	completed	32
25628	9	405.00	5	2025-04-06 19:04:47.807946	2025-04-06 19:26:47.807946	\N	completed	34
25629	12	675.00	5	2025-04-06 16:41:47.807946	2025-04-06 17:28:47.807946	\N	completed	10
25630	15	520.00	5	2025-04-06 21:27:47.807946	2025-04-06 21:56:47.807946	\N	completed	32
25631	16	345.00	5	2025-04-06 15:24:47.807946	2025-04-06 15:55:47.807946	\N	completed	10
25632	16	300.00	8	2025-04-06 09:14:47.807946	2025-04-06 09:59:47.807946	\N	completed	6
25633	11	800.00	7	2025-04-06 07:30:47.807946	2025-04-06 08:15:47.807946	\N	completed	34
25634	15	315.00	4	2025-04-06 10:44:47.807946	2025-04-06 11:18:47.807946	\N	completed	8
25635	2	420.00	7	2025-04-06 05:46:47.807946	2025-04-06 06:10:47.807946	\N	completed	1
25636	16	520.00	8	2025-04-06 22:38:47.807946	2025-04-06 23:22:47.807946	\N	completed	11
25637	30	340.00	9	2025-04-06 06:45:47.807946	2025-04-06 07:09:47.807946	\N	completed	9
25638	11	300.00	4	2025-04-06 12:52:47.807946	2025-04-06 13:13:47.807946	\N	completed	3
25639	16	270.00	6	2025-04-06 15:54:47.807946	2025-04-06 16:27:47.807946	\N	completed	11
25640	10	270.00	6	2025-04-06 19:52:47.807946	2025-04-06 20:34:47.807946	\N	completed	3
25641	16	440.00	4	2025-04-06 21:31:47.807946	2025-04-06 22:13:47.807946	\N	completed	36
25642	8	950.00	9	2025-04-06 18:11:47.807946	2025-04-06 18:39:47.807946	\N	completed	8
25643	15	285.00	6	2025-04-07 19:02:47.807946	2025-04-07 19:30:47.807946	\N	completed	6
25644	7	550.00	4	2025-04-07 08:58:47.807946	2025-04-07 09:48:47.807946	\N	completed	10
25645	15	625.00	4	2025-04-07 07:25:47.807946	2025-04-07 08:11:47.807946	\N	completed	34
25646	7	625.00	5	2025-04-07 07:00:47.807946	2025-04-07 07:21:47.807946	\N	completed	1
25647	9	345.00	7	2025-04-07 19:14:47.807946	2025-04-07 19:40:47.807946	\N	completed	32
25648	30	340.00	7	2025-04-07 22:47:47.807946	2025-04-07 23:07:47.807946	\N	completed	9
25649	15	360.00	4	2025-04-07 13:29:47.807946	2025-04-07 14:12:47.807946	\N	completed	8
25650	7	405.00	7	2025-04-07 09:32:47.807946	2025-04-07 10:18:47.807946	\N	completed	32
25651	28	405.00	7	2025-04-07 15:48:47.807946	2025-04-07 16:18:47.807946	\N	completed	32
25652	12	400.00	4	2025-04-07 05:27:47.807946	2025-04-07 06:12:47.807946	\N	completed	32
25653	12	405.00	7	2025-04-07 13:03:47.807946	2025-04-07 13:26:47.807946	\N	completed	8
25654	7	550.00	4	2025-04-07 16:18:47.807946	2025-04-07 17:06:47.807946	\N	completed	6
25655	15	675.00	5	2025-04-07 17:19:47.807946	2025-04-07 18:00:47.807946	\N	completed	32
25656	10	800.00	8	2025-04-07 16:55:47.807946	2025-04-07 17:25:47.807946	\N	completed	8
25657	9	300.00	8	2025-04-07 06:55:47.807946	2025-04-07 07:22:47.807946	\N	completed	1
25658	9	460.00	6	2025-04-07 05:04:47.807946	2025-04-07 05:34:47.807946	\N	completed	10
25659	16	345.00	5	2025-04-07 10:35:47.807946	2025-04-07 11:24:47.807946	\N	completed	1
25660	11	285.00	4	2025-04-07 14:39:47.807946	2025-04-07 15:05:47.807946	\N	completed	9
25661	7	520.00	8	2025-04-07 20:38:47.807946	2025-04-07 21:05:47.807946	\N	completed	6
25662	12	600.00	5	2025-04-07 21:26:47.807946	2025-04-07 21:48:47.807946	\N	completed	8
25663	30	285.00	9	2025-04-07 19:45:47.807946	2025-04-07 20:15:47.807946	\N	completed	1
25664	28	525.00	5	2025-04-07 11:29:47.807946	2025-04-07 11:59:47.807946	\N	completed	6
25665	12	440.00	9	2025-04-07 21:44:47.807946	2025-04-07 22:14:47.807946	\N	completed	1
25666	28	315.00	9	2025-04-07 10:03:47.807946	2025-04-07 10:45:47.807946	\N	completed	11
25667	11	925.00	7	2025-04-07 17:42:47.807946	2025-04-07 18:03:47.807946	\N	completed	36
25668	10	500.00	9	2025-04-07 06:27:47.807946	2025-04-07 06:52:47.807946	\N	completed	9
25669	16	480.00	6	2025-04-07 13:34:47.807946	2025-04-07 13:54:47.807946	\N	completed	9
25670	14	450.00	5	2025-04-07 19:21:47.807946	2025-04-07 19:47:47.807946	\N	completed	11
25671	7	405.00	5	2025-04-07 14:15:47.807946	2025-04-07 14:51:47.807946	\N	completed	6
25672	12	380.00	8	2025-04-07 05:34:47.807946	2025-04-07 06:10:47.807946	\N	completed	9
25673	7	340.00	9	2025-04-07 06:51:47.807946	2025-04-07 07:41:47.807946	\N	completed	36
25674	7	450.00	9	2025-04-08 12:14:47.807946	2025-04-08 12:49:47.807946	\N	completed	11
25675	16	435.00	7	2025-04-08 12:25:47.807946	2025-04-08 12:52:47.807946	\N	completed	36
25676	7	460.00	8	2025-04-08 20:31:47.807946	2025-04-08 21:09:47.807946	\N	completed	34
25677	28	360.00	5	2025-04-08 10:20:47.807946	2025-04-08 11:10:47.807946	\N	completed	11
25678	2	875.00	7	2025-04-08 16:31:47.807946	2025-04-08 17:00:47.807946	\N	completed	6
25679	7	270.00	4	2025-04-08 15:54:47.807946	2025-04-08 16:19:47.807946	\N	completed	11
25680	30	315.00	5	2025-04-08 15:03:47.807946	2025-04-08 15:27:47.807946	\N	completed	1
25681	7	925.00	5	2025-04-08 17:28:47.807946	2025-04-08 18:15:47.807946	\N	completed	1
25682	10	260.00	5	2025-04-08 06:30:47.807946	2025-04-08 07:09:47.807946	\N	completed	10
25683	9	360.00	9	2025-04-08 21:09:47.807946	2025-04-08 21:43:47.807946	\N	completed	9
25684	11	600.00	6	2025-04-08 16:01:47.807946	2025-04-08 16:29:47.807946	\N	completed	1
25685	12	725.00	5	2025-04-08 08:03:47.807946	2025-04-08 08:26:47.807946	\N	completed	9
25686	30	465.00	9	2025-04-08 14:38:47.807946	2025-04-08 15:25:47.807946	\N	completed	8
25687	12	500.00	6	2025-04-08 20:14:47.807946	2025-04-08 21:01:47.807946	\N	completed	34
25688	28	270.00	8	2025-04-08 13:24:47.807946	2025-04-08 14:10:47.807946	\N	completed	10
25689	16	360.00	4	2025-04-08 21:23:47.807946	2025-04-08 21:50:47.807946	\N	completed	36
25690	2	525.00	5	2025-04-08 10:12:47.807946	2025-04-08 10:45:47.807946	\N	completed	11
25691	30	950.00	6	2025-04-08 17:58:47.807946	2025-04-08 18:43:47.807946	\N	completed	6
25692	7	575.00	8	2025-04-09 16:58:47.807946	2025-04-09 17:31:47.807946	\N	completed	1
25693	16	315.00	9	2025-04-09 15:28:47.807946	2025-04-09 15:48:47.807946	\N	completed	11
25694	10	375.00	7	2025-04-09 19:50:47.807946	2025-04-09 20:38:47.807946	\N	completed	8
25695	14	495.00	8	2025-04-09 15:30:47.807946	2025-04-09 16:03:47.807946	\N	completed	9
25696	7	480.00	9	2025-04-09 05:28:47.807946	2025-04-09 06:16:47.807946	\N	completed	1
25697	30	1025.00	9	2025-04-09 17:29:47.807946	2025-04-09 17:50:47.807946	\N	completed	1
25698	12	360.00	7	2025-04-09 15:46:47.807946	2025-04-09 16:21:47.807946	\N	completed	11
25699	7	380.00	8	2025-04-09 05:05:47.807946	2025-04-09 05:42:47.807946	\N	completed	9
25700	14	450.00	9	2025-04-09 14:00:47.807946	2025-04-09 14:33:47.807946	\N	completed	32
25701	9	875.00	7	2025-04-09 08:11:47.807946	2025-04-09 08:31:47.807946	\N	completed	32
25702	11	600.00	4	2025-04-09 16:32:47.807946	2025-04-09 17:11:47.807946	\N	completed	10
25703	30	480.00	7	2025-04-09 14:29:47.807946	2025-04-09 15:07:47.807946	\N	completed	1
25704	9	650.00	6	2025-04-09 08:06:47.807946	2025-04-09 08:27:47.807946	\N	completed	36
25705	8	465.00	6	2025-04-09 09:12:47.807946	2025-04-09 10:02:47.807946	\N	completed	34
25706	8	315.00	9	2025-04-09 11:29:47.807946	2025-04-09 11:52:47.807946	\N	completed	1
25707	28	420.00	7	2025-04-09 15:33:47.807946	2025-04-09 16:23:47.807946	\N	completed	34
25708	15	330.00	8	2025-04-09 10:15:47.807946	2025-04-09 10:47:47.807946	\N	completed	32
25709	10	465.00	9	2025-04-09 13:42:47.807946	2025-04-09 14:30:47.807946	\N	completed	1
25710	9	520.00	5	2025-04-09 21:30:47.807946	2025-04-09 21:56:47.807946	\N	completed	3
25711	9	380.00	5	2025-04-09 20:39:47.807946	2025-04-09 21:13:47.807946	\N	completed	1
25712	28	825.00	5	2025-04-09 18:21:47.807946	2025-04-09 18:48:47.807946	\N	completed	10
25713	10	775.00	8	2025-04-09 08:37:47.807946	2025-04-09 09:15:47.807946	\N	completed	11
25714	28	550.00	7	2025-04-09 18:46:47.807946	2025-04-09 19:07:47.807946	\N	completed	36
25715	8	270.00	9	2025-04-09 12:20:47.807946	2025-04-09 12:59:47.807946	\N	completed	10
25716	10	600.00	6	2025-04-09 20:56:47.807946	2025-04-09 21:26:47.807946	\N	completed	11
25717	28	435.00	9	2025-04-09 14:42:47.807946	2025-04-09 15:04:47.807946	\N	completed	3
25718	10	1025.00	6	2025-04-09 18:40:47.807946	2025-04-09 19:23:47.807946	\N	completed	36
25719	9	240.00	4	2025-04-10 19:00:47.807946	2025-04-10 19:44:47.807946	\N	completed	3
25720	12	875.00	8	2025-04-10 18:59:47.807946	2025-04-10 19:41:47.807946	\N	completed	10
25721	28	405.00	7	2025-04-10 12:49:47.807946	2025-04-10 13:36:47.807946	\N	completed	6
25722	11	260.00	9	2025-04-10 06:50:47.807946	2025-04-10 07:28:47.807946	\N	completed	9
25723	14	440.00	8	2025-04-10 05:59:47.807946	2025-04-10 06:21:47.807946	\N	completed	1
25724	2	1025.00	5	2025-04-10 07:55:47.807946	2025-04-10 08:15:47.807946	\N	completed	1
25725	28	420.00	8	2025-04-10 21:23:47.807946	2025-04-10 22:12:47.807946	\N	completed	32
25726	10	875.00	5	2025-04-10 18:59:47.807946	2025-04-10 19:40:47.807946	\N	completed	9
25727	8	510.00	7	2025-04-10 14:12:47.807946	2025-04-10 15:00:47.807946	\N	completed	1
25728	16	330.00	8	2025-04-10 19:50:47.807946	2025-04-10 20:18:47.807946	\N	completed	8
25729	8	300.00	9	2025-04-10 09:34:47.807946	2025-04-10 10:03:47.807946	\N	completed	11
25730	16	360.00	6	2025-04-10 11:27:47.807946	2025-04-10 12:06:47.807946	\N	completed	10
25731	14	345.00	5	2025-04-10 13:44:47.807946	2025-04-10 14:21:47.807946	\N	completed	8
25732	30	360.00	7	2025-04-10 05:31:47.807946	2025-04-10 05:52:47.807946	\N	completed	1
25733	8	550.00	5	2025-04-10 18:05:47.807946	2025-04-10 18:27:47.807946	\N	completed	11
25734	2	875.00	7	2025-04-10 08:07:47.807946	2025-04-10 08:35:47.807946	\N	completed	3
25735	30	1000.00	6	2025-04-11 08:39:47.807946	2025-04-11 09:10:47.807946	\N	completed	11
25736	9	625.00	7	2025-04-11 08:02:47.807946	2025-04-11 08:43:47.807946	\N	completed	32
25737	16	725.00	6	2025-04-11 07:21:47.807946	2025-04-11 07:52:47.807946	\N	completed	3
25738	15	750.00	6	2025-04-11 08:57:47.807946	2025-04-11 09:28:47.807946	\N	completed	34
25739	2	320.00	4	2025-04-11 06:33:47.807946	2025-04-11 06:53:47.807946	\N	completed	34
25740	7	375.00	9	2025-04-11 11:27:47.807946	2025-04-11 11:51:47.807946	\N	completed	6
25741	30	420.00	8	2025-04-11 05:08:47.807946	2025-04-11 05:48:47.807946	\N	completed	34
25742	8	480.00	7	2025-04-11 15:34:47.807946	2025-04-11 16:09:47.807946	\N	completed	1
25743	11	525.00	4	2025-04-11 14:06:47.807946	2025-04-11 14:52:47.807946	\N	completed	6
25744	14	480.00	8	2025-04-11 20:41:47.807946	2025-04-11 21:30:47.807946	\N	completed	8
25745	28	345.00	9	2025-04-11 15:54:47.807946	2025-04-11 16:36:47.807946	\N	completed	1
25746	11	420.00	7	2025-04-11 20:29:47.807946	2025-04-11 21:04:47.807946	\N	completed	32
25747	30	495.00	7	2025-04-11 11:11:47.807946	2025-04-11 12:01:47.807946	\N	completed	9
25748	14	625.00	5	2025-04-11 08:17:47.807946	2025-04-11 09:01:47.807946	\N	completed	8
25749	14	380.00	5	2025-04-11 06:17:47.807946	2025-04-11 06:59:47.807946	\N	completed	6
25750	30	520.00	7	2025-04-11 22:09:47.807946	2025-04-11 22:47:47.807946	\N	completed	6
25751	14	450.00	6	2025-04-11 19:29:47.807946	2025-04-11 20:19:47.807946	\N	completed	8
25752	16	480.00	8	2025-04-11 10:58:47.807946	2025-04-11 11:41:47.807946	\N	completed	6
25753	30	400.00	5	2025-04-11 06:34:47.807946	2025-04-11 07:13:47.807946	\N	completed	1
25754	12	1000.00	5	2025-04-11 08:04:47.807946	2025-04-11 08:35:47.807946	\N	completed	34
25755	30	525.00	9	2025-04-11 18:40:47.807946	2025-04-11 19:30:47.807946	\N	completed	34
25756	7	875.00	4	2025-04-11 08:19:47.807946	2025-04-11 08:58:47.807946	\N	completed	9
25757	11	300.00	6	2025-04-11 13:03:47.807946	2025-04-11 13:36:47.807946	\N	completed	36
25758	11	465.00	8	2025-04-11 15:52:47.807946	2025-04-11 16:19:47.807946	\N	completed	6
25759	15	1025.00	8	2025-04-11 18:19:47.807946	2025-04-11 18:59:47.807946	\N	completed	34
25760	16	360.00	4	2025-04-11 20:20:47.807946	2025-04-11 21:01:47.807946	\N	completed	9
25761	30	405.00	4	2025-04-11 11:47:47.807946	2025-04-11 12:12:47.807946	\N	completed	9
25762	12	450.00	9	2025-04-11 15:52:47.807946	2025-04-11 16:34:47.807946	\N	completed	32
25763	14	875.00	6	2025-04-12 16:35:47.807946	2025-04-12 17:01:47.807946	\N	completed	11
25764	8	580.00	7	2025-04-12 21:48:47.807946	2025-04-12 22:17:47.807946	\N	completed	11
25765	15	405.00	7	2025-04-12 19:28:47.807946	2025-04-12 20:02:47.807946	\N	completed	8
25766	9	300.00	7	2025-04-12 10:31:47.807946	2025-04-12 11:12:47.807946	\N	completed	6
25767	9	510.00	8	2025-04-12 10:45:47.807946	2025-04-12 11:13:47.807946	\N	completed	9
25768	30	420.00	4	2025-04-12 19:19:47.807946	2025-04-12 19:54:47.807946	\N	completed	34
25769	11	360.00	8	2025-04-12 22:57:47.807946	2025-04-12 23:17:47.807946	\N	completed	8
25770	8	360.00	6	2025-04-12 05:17:47.807946	2025-04-12 05:51:47.807946	\N	completed	34
25771	12	260.00	4	2025-04-12 06:13:47.807946	2025-04-12 06:43:47.807946	\N	completed	6
25772	12	320.00	4	2025-04-12 22:12:47.807946	2025-04-12 22:36:47.807946	\N	completed	1
25773	7	800.00	8	2025-04-12 18:05:47.807946	2025-04-12 18:32:47.807946	\N	completed	36
25774	12	495.00	4	2025-04-12 09:33:47.807946	2025-04-12 10:00:47.807946	\N	completed	9
25775	12	560.00	5	2025-04-12 21:34:47.807946	2025-04-12 22:22:47.807946	\N	completed	3
25776	8	360.00	5	2025-04-12 13:15:47.807946	2025-04-12 13:54:47.807946	\N	completed	9
25777	12	315.00	5	2025-04-12 15:21:47.807946	2025-04-12 16:08:47.807946	\N	completed	10
25778	14	330.00	5	2025-04-12 10:05:47.807946	2025-04-12 10:32:47.807946	\N	completed	32
25779	9	525.00	9	2025-04-12 14:06:47.807946	2025-04-12 14:44:47.807946	\N	completed	10
25780	15	360.00	5	2025-04-12 06:45:47.807946	2025-04-12 07:34:47.807946	\N	completed	34
25781	14	420.00	4	2025-04-12 05:44:47.807946	2025-04-12 06:05:47.807946	\N	completed	34
25782	28	600.00	9	2025-04-12 08:37:47.807946	2025-04-12 09:23:47.807946	\N	completed	8
25783	30	300.00	6	2025-04-12 22:05:47.807946	2025-04-12 22:40:47.807946	\N	completed	1
25784	8	495.00	4	2025-04-12 10:38:47.807946	2025-04-12 11:18:47.807946	\N	completed	6
25785	12	420.00	9	2025-04-12 15:09:47.807946	2025-04-12 15:51:47.807946	\N	completed	10
25786	2	500.00	8	2025-04-13 06:34:47.807946	2025-04-13 07:23:47.807946	\N	completed	34
25787	7	460.00	9	2025-04-13 22:58:47.807946	2025-04-13 23:42:47.807946	\N	completed	8
25788	12	400.00	6	2025-04-13 05:37:47.807946	2025-04-13 06:21:47.807946	\N	completed	8
25789	12	390.00	5	2025-04-13 15:27:47.807946	2025-04-13 16:11:47.807946	\N	completed	3
25790	8	480.00	4	2025-04-13 22:07:47.807946	2025-04-13 22:55:47.807946	\N	completed	11
25791	15	480.00	6	2025-04-13 14:50:47.807946	2025-04-13 15:13:47.807946	\N	completed	11
25792	10	435.00	9	2025-04-13 14:58:47.807946	2025-04-13 15:37:47.807946	\N	completed	6
25793	16	345.00	4	2025-04-13 11:24:47.807946	2025-04-13 12:02:47.807946	\N	completed	36
25794	8	435.00	4	2025-04-13 10:16:47.807946	2025-04-13 10:44:47.807946	\N	completed	8
25795	16	450.00	7	2025-04-13 15:21:47.807946	2025-04-13 16:03:47.807946	\N	completed	1
25796	7	480.00	5	2025-04-13 05:38:47.807946	2025-04-13 05:59:47.807946	\N	completed	36
25797	16	270.00	9	2025-04-13 19:33:47.807946	2025-04-13 20:03:47.807946	\N	completed	1
25798	11	315.00	4	2025-04-13 10:36:47.807946	2025-04-13 11:01:47.807946	\N	completed	6
25799	2	450.00	9	2025-04-13 14:31:47.807946	2025-04-13 14:51:47.807946	\N	completed	11
25800	28	480.00	5	2025-04-13 10:09:47.807946	2025-04-13 10:47:47.807946	\N	completed	36
25801	11	280.00	6	2025-04-13 06:22:47.807946	2025-04-13 06:59:47.807946	\N	completed	34
25802	2	420.00	6	2025-04-13 06:38:47.807946	2025-04-13 07:08:47.807946	\N	completed	11
25803	11	750.00	4	2025-04-13 16:01:47.807946	2025-04-13 16:29:47.807946	\N	completed	9
25804	16	255.00	7	2025-04-13 19:02:47.807946	2025-04-13 19:39:47.807946	\N	completed	36
25805	15	550.00	7	2025-04-13 17:34:47.807946	2025-04-13 18:09:47.807946	\N	completed	9
25806	16	340.00	7	2025-04-13 06:36:47.807946	2025-04-13 07:04:47.807946	\N	completed	11
25807	12	725.00	8	2025-04-13 16:27:47.807946	2025-04-13 17:14:47.807946	\N	completed	6
25808	14	405.00	6	2025-04-13 15:40:47.807946	2025-04-13 16:29:47.807946	\N	completed	9
25809	7	540.00	4	2025-04-13 20:50:47.807946	2025-04-13 21:25:47.807946	\N	completed	34
25810	16	360.00	6	2025-04-13 06:51:47.807946	2025-04-13 07:22:47.807946	\N	completed	6
25811	12	580.00	4	2025-04-13 21:29:47.807946	2025-04-13 22:01:47.807946	\N	completed	11
25812	14	420.00	6	2025-04-14 19:50:47.807946	2025-04-14 20:12:47.807946	\N	completed	11
25813	2	850.00	6	2025-04-14 16:45:47.807946	2025-04-14 17:09:47.807946	\N	completed	11
25814	14	400.00	7	2025-04-14 20:24:47.807946	2025-04-14 21:00:47.807946	\N	completed	36
25815	10	550.00	4	2025-04-14 16:04:47.807946	2025-04-14 16:29:47.807946	\N	completed	8
25816	30	495.00	9	2025-04-14 10:34:47.807946	2025-04-14 11:12:47.807946	\N	completed	32
25817	12	270.00	4	2025-04-14 12:22:47.807946	2025-04-14 12:59:47.807946	\N	completed	6
25818	15	465.00	9	2025-04-14 09:02:47.807946	2025-04-14 09:40:47.807946	\N	completed	8
25819	16	300.00	6	2025-04-14 20:19:47.807946	2025-04-14 20:41:47.807946	\N	completed	36
25820	12	465.00	4	2025-04-14 12:27:47.807946	2025-04-14 13:15:47.807946	\N	completed	32
25821	16	285.00	4	2025-04-14 14:00:47.807946	2025-04-14 14:34:47.807946	\N	completed	11
25822	7	400.00	5	2025-04-14 22:11:47.807946	2025-04-14 22:51:47.807946	\N	completed	11
25823	10	465.00	6	2025-04-14 12:27:47.807946	2025-04-14 12:55:47.807946	\N	completed	34
25824	9	375.00	7	2025-04-14 19:35:47.807946	2025-04-14 20:25:47.807946	\N	completed	10
25825	16	925.00	8	2025-04-14 17:43:47.807946	2025-04-14 18:19:47.807946	\N	completed	36
25826	11	405.00	8	2025-04-14 09:51:47.807946	2025-04-14 10:35:47.807946	\N	completed	6
25827	14	750.00	5	2025-04-14 16:59:47.807946	2025-04-14 17:25:47.807946	\N	completed	6
25828	10	320.00	9	2025-04-14 21:48:47.807946	2025-04-14 22:36:47.807946	\N	completed	34
25829	7	875.00	7	2025-04-15 18:14:47.807946	2025-04-15 18:50:47.807946	\N	completed	10
25830	12	500.00	4	2025-04-15 21:51:47.807946	2025-04-15 22:23:47.807946	\N	completed	34
25831	10	700.00	4	2025-04-15 16:03:47.807946	2025-04-15 16:44:47.807946	\N	completed	3
25832	28	875.00	9	2025-04-15 08:17:47.807946	2025-04-15 08:42:47.807946	\N	completed	36
25833	8	520.00	9	2025-04-15 21:10:47.807946	2025-04-15 21:34:47.807946	\N	completed	8
25834	7	330.00	9	2025-04-15 19:19:47.807946	2025-04-15 19:50:47.807946	\N	completed	9
25835	16	1000.00	9	2025-04-15 08:42:47.807946	2025-04-15 09:04:47.807946	\N	completed	36
25836	8	495.00	4	2025-04-15 11:05:47.807946	2025-04-15 11:28:47.807946	\N	completed	1
25837	10	460.00	6	2025-04-15 05:05:47.807946	2025-04-15 05:53:47.807946	\N	completed	8
25838	15	330.00	5	2025-04-15 14:50:47.807946	2025-04-15 15:19:47.807946	\N	completed	3
25839	7	360.00	6	2025-04-15 22:24:47.807946	2025-04-15 22:59:47.807946	\N	completed	32
25840	7	360.00	5	2025-04-15 19:04:47.807946	2025-04-15 19:53:47.807946	\N	completed	1
25841	14	540.00	8	2025-04-15 21:32:47.807946	2025-04-15 22:19:47.807946	\N	completed	11
25842	16	225.00	7	2025-04-15 19:07:47.807946	2025-04-15 19:31:47.807946	\N	completed	8
25843	11	405.00	8	2025-04-15 11:38:47.807946	2025-04-15 12:00:47.807946	\N	completed	32
25844	12	420.00	4	2025-04-15 10:36:47.807946	2025-04-15 11:11:47.807946	\N	completed	34
25845	12	340.00	5	2025-04-15 20:01:47.807946	2025-04-15 20:32:47.807946	\N	completed	11
25846	10	320.00	8	2025-04-15 06:24:47.807946	2025-04-15 07:04:47.807946	\N	completed	9
25847	30	300.00	5	2025-04-15 15:55:47.807946	2025-04-15 16:37:47.807946	\N	completed	34
25848	11	520.00	5	2025-04-15 21:58:47.807946	2025-04-15 22:37:47.807946	\N	completed	11
25849	14	300.00	8	2025-04-15 19:40:47.807946	2025-04-15 20:03:47.807946	\N	completed	6
25850	15	405.00	9	2025-04-15 19:57:47.807946	2025-04-15 20:47:47.807946	\N	completed	6
25851	9	420.00	7	2025-04-15 13:08:47.807946	2025-04-15 13:48:47.807946	\N	completed	6
25852	2	1025.00	6	2025-04-15 17:33:47.807946	2025-04-15 17:54:47.807946	\N	completed	34
25853	7	580.00	7	2025-04-15 20:13:47.807946	2025-04-15 20:42:47.807946	\N	completed	11
25854	9	975.00	9	2025-04-16 18:28:47.807946	2025-04-16 18:49:47.807946	\N	completed	6
25855	30	495.00	4	2025-04-16 15:50:47.807946	2025-04-16 16:27:47.807946	\N	completed	36
25856	15	435.00	9	2025-04-16 11:50:47.807946	2025-04-16 12:10:47.807946	\N	completed	11
25857	14	375.00	9	2025-04-16 14:34:47.807946	2025-04-16 15:22:47.807946	\N	completed	6
25858	2	340.00	9	2025-04-16 22:38:47.807946	2025-04-16 23:09:47.807946	\N	completed	11
25859	15	650.00	8	2025-04-16 07:51:47.807946	2025-04-16 08:31:47.807946	\N	completed	34
25860	14	650.00	7	2025-04-16 08:53:47.807946	2025-04-16 09:23:47.807946	\N	completed	8
25861	12	975.00	9	2025-04-16 16:29:47.807946	2025-04-16 17:01:47.807946	\N	completed	8
25862	7	800.00	7	2025-04-16 17:22:47.807946	2025-04-16 18:02:47.807946	\N	completed	1
25863	14	850.00	8	2025-04-16 18:50:47.807946	2025-04-16 19:37:47.807946	\N	completed	9
25864	15	700.00	9	2025-04-16 17:34:47.807946	2025-04-16 18:10:47.807946	\N	completed	11
25865	8	775.00	7	2025-04-16 16:37:47.807946	2025-04-16 17:06:47.807946	\N	completed	32
25866	28	465.00	4	2025-04-16 12:40:47.807946	2025-04-16 13:14:47.807946	\N	completed	34
25867	9	480.00	6	2025-04-16 09:41:47.807946	2025-04-16 10:30:47.807946	\N	completed	3
25868	30	800.00	4	2025-04-16 08:53:47.807946	2025-04-16 09:42:47.807946	\N	completed	32
25869	10	330.00	6	2025-04-16 09:02:47.807946	2025-04-16 09:39:47.807946	\N	completed	10
25870	10	450.00	8	2025-04-17 19:23:47.807946	2025-04-17 19:51:47.807946	\N	completed	6
25871	8	925.00	8	2025-04-17 16:45:47.807946	2025-04-17 17:29:47.807946	\N	completed	10
25872	7	450.00	4	2025-04-17 12:30:47.807946	2025-04-17 12:56:47.807946	\N	completed	32
25873	30	280.00	7	2025-04-17 05:57:47.807946	2025-04-17 06:20:47.807946	\N	completed	1
25874	15	380.00	9	2025-04-17 05:04:47.807946	2025-04-17 05:49:47.807946	\N	completed	34
25875	14	480.00	7	2025-04-17 14:02:47.807946	2025-04-17 14:24:47.807946	\N	completed	10
25876	8	525.00	4	2025-04-17 13:39:47.807946	2025-04-17 14:15:47.807946	\N	completed	11
25877	16	380.00	5	2025-04-17 06:45:47.807946	2025-04-17 07:20:47.807946	\N	completed	11
25878	10	330.00	8	2025-04-17 12:58:47.807946	2025-04-17 13:30:47.807946	\N	completed	11
25879	10	420.00	5	2025-04-17 15:06:47.807946	2025-04-17 15:35:47.807946	\N	completed	6
25880	10	400.00	5	2025-04-17 20:05:47.807946	2025-04-17 20:50:47.807946	\N	completed	6
25881	9	300.00	7	2025-04-17 06:37:47.807946	2025-04-17 07:22:47.807946	\N	completed	32
25882	30	375.00	5	2025-04-17 19:19:47.807946	2025-04-17 19:53:47.807946	\N	completed	32
25883	10	500.00	7	2025-04-17 22:44:47.807946	2025-04-17 23:30:47.807946	\N	completed	9
25884	7	450.00	8	2025-04-17 14:42:47.807946	2025-04-17 15:32:47.807946	\N	completed	10
25885	30	625.00	9	2025-04-17 17:03:47.807946	2025-04-17 17:25:47.807946	\N	completed	1
25886	14	405.00	8	2025-04-17 12:40:47.807946	2025-04-17 13:25:47.807946	\N	completed	32
25887	7	330.00	7	2025-04-17 11:16:47.807946	2025-04-17 12:00:47.807946	\N	completed	9
25888	16	280.00	5	2025-04-17 06:19:47.807946	2025-04-17 06:46:47.807946	\N	completed	36
25889	7	800.00	6	2025-04-17 07:23:47.807946	2025-04-17 08:13:47.807946	\N	completed	9
25890	28	300.00	4	2025-04-17 06:15:47.807946	2025-04-17 06:46:47.807946	\N	completed	10
25891	28	775.00	4	2025-04-17 08:29:47.807946	2025-04-17 09:09:47.807946	\N	completed	36
25892	10	225.00	6	2025-04-18 19:23:47.807946	2025-04-18 19:50:47.807946	\N	completed	8
25893	28	300.00	6	2025-04-18 15:11:47.807946	2025-04-18 15:32:47.807946	\N	completed	3
25894	7	580.00	8	2025-04-18 22:37:47.807946	2025-04-18 23:03:47.807946	\N	completed	6
25895	8	400.00	9	2025-04-18 05:13:47.807946	2025-04-18 05:52:47.807946	\N	completed	32
25896	14	450.00	5	2025-04-18 19:14:47.807946	2025-04-18 19:55:47.807946	\N	completed	36
25897	12	510.00	6	2025-04-18 15:06:47.807946	2025-04-18 15:30:47.807946	\N	completed	3
25898	7	300.00	8	2025-04-18 11:22:47.807946	2025-04-18 12:12:47.807946	\N	completed	32
25899	30	400.00	6	2025-04-18 05:52:47.807946	2025-04-18 06:15:47.807946	\N	completed	10
25900	2	450.00	4	2025-04-18 13:13:47.807946	2025-04-18 13:42:47.807946	\N	completed	32
25901	15	405.00	7	2025-04-18 14:27:47.807946	2025-04-18 15:14:47.807946	\N	completed	34
25902	7	520.00	7	2025-04-18 21:54:47.807946	2025-04-18 22:22:47.807946	\N	completed	6
25903	9	320.00	6	2025-04-18 20:59:47.807946	2025-04-18 21:23:47.807946	\N	completed	1
25904	30	480.00	4	2025-04-18 09:14:47.807946	2025-04-18 09:48:47.807946	\N	completed	6
25905	8	260.00	4	2025-04-18 06:13:47.807946	2025-04-18 06:44:47.807946	\N	completed	10
25906	16	315.00	4	2025-04-18 10:42:47.807946	2025-04-18 11:10:47.807946	\N	completed	6
25907	8	255.00	6	2025-04-18 19:53:47.807946	2025-04-18 20:38:47.807946	\N	completed	8
25908	7	625.00	5	2025-04-18 18:42:47.807946	2025-04-18 19:29:47.807946	\N	completed	10
25909	30	465.00	7	2025-04-18 12:33:47.807946	2025-04-18 12:56:47.807946	\N	completed	6
25910	9	300.00	4	2025-04-18 12:05:47.807946	2025-04-18 12:42:47.807946	\N	completed	32
25911	11	775.00	5	2025-04-18 18:21:47.807946	2025-04-18 18:45:47.807946	\N	completed	6
25912	7	510.00	4	2025-04-18 15:26:47.807946	2025-04-18 15:48:47.807946	\N	completed	32
25913	10	975.00	6	2025-04-19 07:26:47.807946	2025-04-19 07:57:47.807946	\N	completed	1
25914	15	950.00	4	2025-04-19 17:09:47.807946	2025-04-19 17:46:47.807946	\N	completed	34
25915	9	360.00	7	2025-04-19 19:41:47.807946	2025-04-19 20:21:47.807946	\N	completed	1
25916	30	345.00	9	2025-04-19 12:22:47.807946	2025-04-19 13:08:47.807946	\N	completed	32
25917	16	420.00	6	2025-04-19 06:52:47.807946	2025-04-19 07:39:47.807946	\N	completed	32
25918	9	440.00	6	2025-04-19 05:44:47.807946	2025-04-19 06:12:47.807946	\N	completed	34
25919	28	540.00	4	2025-04-19 22:46:47.807946	2025-04-19 23:25:47.807946	\N	completed	36
25920	14	540.00	7	2025-04-19 21:41:47.807946	2025-04-19 22:02:47.807946	\N	completed	32
25921	16	975.00	8	2025-04-19 17:39:47.807946	2025-04-19 18:04:47.807946	\N	completed	6
25922	30	330.00	7	2025-04-19 15:16:47.807946	2025-04-19 15:58:47.807946	\N	completed	1
25923	15	270.00	4	2025-04-19 19:42:47.807946	2025-04-19 20:32:47.807946	\N	completed	3
25924	8	420.00	6	2025-04-19 14:04:47.807946	2025-04-19 14:24:47.807946	\N	completed	6
25925	9	420.00	9	2025-04-19 13:45:47.807946	2025-04-19 14:11:47.807946	\N	completed	32
25926	15	975.00	5	2025-04-19 08:38:47.807946	2025-04-19 09:08:47.807946	\N	completed	3
25927	10	495.00	9	2025-04-19 12:47:47.807946	2025-04-19 13:17:47.807946	\N	completed	9
25928	16	270.00	7	2025-04-19 10:19:47.807946	2025-04-19 10:39:47.807946	\N	completed	6
25929	16	375.00	4	2025-04-19 10:40:47.807946	2025-04-19 11:05:47.807946	\N	completed	1
25930	30	340.00	8	2025-04-19 06:19:47.807946	2025-04-19 06:40:47.807946	\N	completed	11
25931	14	360.00	5	2025-04-19 20:22:47.807946	2025-04-19 21:11:47.807946	\N	completed	8
25932	2	580.00	4	2025-04-19 21:13:47.807946	2025-04-19 21:56:47.807946	\N	completed	32
25933	28	345.00	7	2025-04-19 09:41:47.807946	2025-04-19 10:12:47.807946	\N	completed	32
25934	28	270.00	8	2025-04-19 14:54:47.807946	2025-04-19 15:35:47.807946	\N	completed	1
25935	7	420.00	5	2025-04-19 09:04:47.807946	2025-04-19 09:29:47.807946	\N	completed	9
25936	10	575.00	5	2025-04-19 18:36:47.807946	2025-04-19 19:08:47.807946	\N	completed	3
25937	11	510.00	7	2025-04-19 13:18:47.807946	2025-04-19 13:38:47.807946	\N	completed	6
25938	7	1000.00	6	2025-04-19 18:15:47.807946	2025-04-19 18:35:47.807946	\N	completed	36
25939	7	575.00	6	2025-04-19 18:39:47.807946	2025-04-19 19:15:47.807946	\N	completed	32
25940	8	625.00	7	2025-04-19 16:01:47.807946	2025-04-19 16:30:47.807946	\N	completed	32
25941	2	375.00	9	2025-04-19 09:48:47.807946	2025-04-19 10:23:47.807946	\N	completed	1
25942	15	420.00	9	2025-04-20 22:11:47.807946	2025-04-20 22:40:47.807946	\N	completed	8
25943	9	900.00	7	2025-04-20 16:07:47.807946	2025-04-20 16:51:47.807946	\N	completed	11
25944	10	480.00	4	2025-04-20 06:47:47.807946	2025-04-20 07:30:47.807946	\N	completed	1
25945	8	500.00	4	2025-04-20 05:37:47.807946	2025-04-20 06:18:47.807946	\N	completed	3
25946	9	420.00	5	2025-04-20 15:23:47.807946	2025-04-20 15:48:47.807946	\N	completed	9
25947	16	510.00	7	2025-04-20 13:24:47.807946	2025-04-20 14:07:47.807946	\N	completed	32
25948	7	580.00	9	2025-04-20 22:08:47.807946	2025-04-20 22:34:47.807946	\N	completed	34
25949	14	390.00	8	2025-04-20 09:22:47.807946	2025-04-20 09:43:47.807946	\N	completed	9
25950	10	270.00	7	2025-04-20 19:48:47.807946	2025-04-20 20:25:47.807946	\N	completed	32
25951	28	405.00	5	2025-04-20 10:21:47.807946	2025-04-20 11:06:47.807946	\N	completed	32
25952	10	345.00	8	2025-04-20 13:45:47.807946	2025-04-20 14:20:47.807946	\N	completed	36
25953	12	400.00	8	2025-04-20 06:42:47.807946	2025-04-20 07:25:47.807946	\N	completed	6
25954	16	300.00	6	2025-04-20 15:47:47.807946	2025-04-20 16:22:47.807946	\N	completed	6
25955	10	330.00	7	2025-04-20 13:39:47.807946	2025-04-20 14:02:47.807946	\N	completed	6
25956	11	390.00	5	2025-04-20 10:25:47.807946	2025-04-20 11:02:47.807946	\N	completed	6
25957	16	465.00	7	2025-04-20 14:44:47.807946	2025-04-20 15:21:47.807946	\N	completed	36
25958	9	420.00	9	2025-04-20 13:48:47.807946	2025-04-20 14:26:47.807946	\N	completed	11
25959	9	675.00	7	2025-04-20 18:10:47.807946	2025-04-20 18:39:47.807946	\N	completed	32
25960	12	550.00	9	2025-04-20 18:26:47.807946	2025-04-20 18:58:47.807946	\N	completed	3
25961	8	375.00	4	2025-04-20 13:31:47.807946	2025-04-20 14:07:47.807946	\N	completed	32
25962	7	700.00	4	2025-04-21 17:03:47.807946	2025-04-21 17:42:47.807946	\N	completed	11
25963	16	1025.00	6	2025-04-21 18:56:47.807946	2025-04-21 19:29:47.807946	\N	completed	34
25964	12	270.00	6	2025-04-21 09:35:47.807946	2025-04-21 10:04:47.807946	\N	completed	1
25965	8	400.00	4	2025-04-21 05:03:47.807946	2025-04-21 05:33:47.807946	\N	completed	6
25966	2	825.00	6	2025-04-21 18:02:47.807946	2025-04-21 18:40:47.807946	\N	completed	3
25967	10	775.00	9	2025-04-21 17:08:47.807946	2025-04-21 17:44:47.807946	\N	completed	32
25968	8	400.00	8	2025-04-21 21:51:47.807946	2025-04-21 22:26:47.807946	\N	completed	10
25969	15	510.00	5	2025-04-21 12:36:47.807946	2025-04-21 13:25:47.807946	\N	completed	8
25970	14	480.00	9	2025-04-21 06:46:47.807946	2025-04-21 07:19:47.807946	\N	completed	8
25971	11	375.00	9	2025-04-21 13:08:47.807946	2025-04-21 13:51:47.807946	\N	completed	6
25972	28	600.00	6	2025-04-21 08:19:47.807946	2025-04-21 08:44:47.807946	\N	completed	36
25973	16	330.00	8	2025-04-21 13:18:47.807946	2025-04-21 14:02:47.807946	\N	completed	8
25974	28	450.00	5	2025-04-21 10:27:47.807946	2025-04-21 11:00:47.807946	\N	completed	10
25975	16	580.00	9	2025-04-21 20:58:47.807946	2025-04-21 21:35:47.807946	\N	completed	10
25976	7	825.00	6	2025-04-21 18:50:47.807946	2025-04-21 19:33:47.807946	\N	completed	6
25977	14	315.00	9	2025-04-21 10:36:47.807946	2025-04-21 11:23:47.807946	\N	completed	1
25978	12	330.00	7	2025-04-21 19:55:47.807946	2025-04-21 20:44:47.807946	\N	completed	1
25979	12	480.00	5	2025-04-21 22:06:47.807946	2025-04-21 22:42:47.807946	\N	completed	32
25980	11	775.00	7	2025-04-21 07:26:47.807946	2025-04-21 08:00:47.807946	\N	completed	9
25981	12	320.00	6	2025-04-21 05:40:47.807946	2025-04-21 06:17:47.807946	\N	completed	10
25982	30	440.00	5	2025-04-21 06:09:47.807946	2025-04-21 06:35:47.807946	\N	completed	8
25983	7	465.00	7	2025-04-21 14:01:47.807946	2025-04-21 14:33:47.807946	\N	completed	6
25984	12	480.00	8	2025-04-21 13:38:47.807946	2025-04-21 14:07:47.807946	\N	completed	1
25985	14	270.00	6	2025-04-21 15:43:47.807946	2025-04-21 16:28:47.807946	\N	completed	1
25986	8	460.00	5	2025-04-21 20:01:47.807946	2025-04-21 20:38:47.807946	\N	completed	36
25987	14	390.00	5	2025-04-21 10:09:47.807946	2025-04-21 10:30:47.807946	\N	completed	6
25988	8	950.00	4	2025-04-21 17:19:47.807946	2025-04-21 18:05:47.807946	\N	completed	32
25989	10	525.00	4	2025-04-22 07:12:47.807946	2025-04-22 07:55:47.807946	\N	completed	11
25990	28	580.00	7	2025-04-22 22:31:47.807946	2025-04-22 23:16:47.807946	\N	completed	36
25991	9	675.00	8	2025-04-22 18:49:47.807946	2025-04-22 19:37:47.807946	\N	completed	3
25992	2	575.00	5	2025-04-22 08:33:47.807946	2025-04-22 08:54:47.807946	\N	completed	8
25993	9	420.00	4	2025-04-22 21:31:47.807946	2025-04-22 21:53:47.807946	\N	completed	3
25994	30	480.00	6	2025-04-22 20:04:47.807946	2025-04-22 20:35:47.807946	\N	completed	3
25995	30	360.00	4	2025-04-22 20:32:47.807946	2025-04-22 21:19:47.807946	\N	completed	6
25996	14	390.00	7	2025-04-22 19:43:47.807946	2025-04-22 20:04:47.807946	\N	completed	3
25997	10	375.00	6	2025-04-22 12:16:47.807946	2025-04-22 12:40:47.807946	\N	completed	8
25998	9	925.00	9	2025-04-22 08:51:47.807946	2025-04-22 09:38:47.807946	\N	completed	3
25999	7	850.00	7	2025-04-22 16:43:47.807946	2025-04-22 17:13:47.807946	\N	completed	32
26000	7	495.00	6	2025-04-22 13:09:47.807946	2025-04-22 13:30:47.807946	\N	completed	10
26001	14	510.00	6	2025-04-22 15:00:47.807946	2025-04-22 15:30:47.807946	\N	completed	6
26002	28	320.00	4	2025-04-22 05:53:47.807946	2025-04-22 06:21:47.807946	\N	completed	34
26003	9	480.00	8	2025-04-22 15:04:47.807946	2025-04-22 15:35:47.807946	\N	completed	6
26004	2	495.00	9	2025-04-22 15:59:47.807946	2025-04-22 16:32:47.807946	\N	completed	3
26005	12	460.00	9	2025-04-22 05:33:47.807946	2025-04-22 06:22:47.807946	\N	completed	11
26006	11	525.00	4	2025-04-22 08:45:47.807946	2025-04-22 09:26:47.807946	\N	completed	6
26007	10	340.00	4	2025-04-22 05:57:47.807946	2025-04-22 06:35:47.807946	\N	completed	3
26008	30	600.00	6	2025-04-22 17:51:47.807946	2025-04-22 18:26:47.807946	\N	completed	34
26009	11	300.00	6	2025-04-22 14:54:47.807946	2025-04-22 15:18:47.807946	\N	completed	36
26010	10	525.00	5	2025-04-22 17:50:47.807946	2025-04-22 18:38:47.807946	\N	completed	34
26011	8	360.00	6	2025-04-22 10:00:47.807946	2025-04-22 10:35:47.807946	\N	completed	8
26012	30	420.00	9	2025-04-22 10:37:47.807946	2025-04-22 11:24:47.807946	\N	completed	11
26013	15	525.00	7	2025-04-22 17:26:47.807946	2025-04-22 18:15:47.807946	\N	completed	3
26014	16	390.00	5	2025-04-22 09:03:47.807946	2025-04-22 09:27:47.807946	\N	completed	3
26015	11	800.00	7	2025-04-22 17:02:47.807946	2025-04-22 17:36:47.807946	\N	completed	6
26016	30	750.00	6	2025-04-22 08:43:47.807946	2025-04-22 09:26:47.807946	\N	completed	10
26017	2	285.00	8	2025-04-22 15:25:47.807946	2025-04-22 16:05:47.807946	\N	completed	6
26018	2	340.00	8	2025-04-23 21:18:47.807946	2025-04-23 21:43:47.807946	\N	completed	9
26019	11	435.00	7	2025-04-23 12:35:47.807946	2025-04-23 13:25:47.807946	\N	completed	3
26020	28	525.00	8	2025-04-23 09:30:47.807946	2025-04-23 10:00:47.807946	\N	completed	10
26021	14	510.00	8	2025-04-23 14:53:47.807946	2025-04-23 15:34:47.807946	\N	completed	6
26022	28	975.00	7	2025-04-23 17:23:47.807946	2025-04-23 18:04:47.807946	\N	completed	36
26023	30	460.00	5	2025-04-23 05:17:47.807946	2025-04-23 05:48:47.807946	\N	completed	1
26024	16	320.00	8	2025-04-23 22:45:47.807946	2025-04-23 23:17:47.807946	\N	completed	36
26025	8	280.00	4	2025-04-23 06:18:47.807946	2025-04-23 06:50:47.807946	\N	completed	11
26026	9	495.00	8	2025-04-23 15:25:47.807946	2025-04-23 16:03:47.807946	\N	completed	1
26027	10	440.00	8	2025-04-23 21:17:47.807946	2025-04-23 21:52:47.807946	\N	completed	9
26028	14	450.00	6	2025-04-23 10:13:47.807946	2025-04-23 10:58:47.807946	\N	completed	9
26029	10	435.00	5	2025-04-23 15:30:47.807946	2025-04-23 15:51:47.807946	\N	completed	36
26030	9	500.00	7	2025-04-23 22:34:47.807946	2025-04-23 23:15:47.807946	\N	completed	1
26031	15	320.00	7	2025-04-23 22:44:47.807946	2025-04-23 23:13:47.807946	\N	completed	34
26032	16	420.00	9	2025-04-23 19:18:47.807946	2025-04-23 19:51:47.807946	\N	completed	8
26033	2	800.00	4	2025-04-23 16:45:47.807946	2025-04-23 17:09:47.807946	\N	completed	3
26034	10	850.00	5	2025-04-23 08:20:47.807946	2025-04-23 08:54:47.807946	\N	completed	8
26035	8	525.00	6	2025-04-23 08:42:47.807946	2025-04-23 09:07:47.807946	\N	completed	11
26036	16	390.00	9	2025-04-23 19:25:47.807946	2025-04-23 20:10:47.807946	\N	completed	36
26037	14	280.00	4	2025-04-24 05:05:47.807946	2025-04-24 05:44:47.807946	\N	completed	1
26038	7	775.00	7	2025-04-24 08:15:47.807946	2025-04-24 08:43:47.807946	\N	completed	34
26039	30	420.00	7	2025-04-24 15:46:47.807946	2025-04-24 16:08:47.807946	\N	completed	11
26040	16	420.00	7	2025-04-24 19:43:47.807946	2025-04-24 20:23:47.807946	\N	completed	3
26041	28	480.00	4	2025-04-24 20:52:47.807946	2025-04-24 21:37:47.807946	\N	completed	11
26042	12	495.00	7	2025-04-24 13:56:47.807946	2025-04-24 14:39:47.807946	\N	completed	6
26043	2	345.00	6	2025-04-24 19:38:47.807946	2025-04-24 20:24:47.807946	\N	completed	1
26044	2	775.00	8	2025-04-24 07:47:47.807946	2025-04-24 08:13:47.807946	\N	completed	34
26045	10	300.00	7	2025-04-24 15:00:47.807946	2025-04-24 15:49:47.807946	\N	completed	6
26046	28	390.00	7	2025-04-24 19:27:47.807946	2025-04-24 19:51:47.807946	\N	completed	6
26047	12	500.00	9	2025-04-24 05:30:47.807946	2025-04-24 06:08:47.807946	\N	completed	3
26048	10	775.00	5	2025-04-24 18:00:47.807946	2025-04-24 18:39:47.807946	\N	completed	32
26049	16	315.00	5	2025-04-24 09:13:47.807946	2025-04-24 09:35:47.807946	\N	completed	34
26050	15	525.00	6	2025-04-24 15:37:47.807946	2025-04-24 15:57:47.807946	\N	completed	36
26051	10	420.00	9	2025-04-24 19:02:47.807946	2025-04-24 19:37:47.807946	\N	completed	9
26052	16	875.00	6	2025-04-24 16:08:47.807946	2025-04-24 16:48:47.807946	\N	completed	6
26053	15	850.00	6	2025-04-25 17:04:47.807946	2025-04-25 17:24:47.807946	\N	completed	6
26054	9	460.00	6	2025-04-25 05:46:47.807946	2025-04-25 06:36:47.807946	\N	completed	36
26055	30	580.00	9	2025-04-25 22:15:47.807946	2025-04-25 22:50:47.807946	\N	completed	36
26056	28	390.00	4	2025-04-25 12:59:47.807946	2025-04-25 13:36:47.807946	\N	completed	6
26057	9	500.00	9	2025-04-25 05:19:47.807946	2025-04-25 06:05:47.807946	\N	completed	9
26058	28	280.00	5	2025-04-25 05:01:47.807946	2025-04-25 05:51:47.807946	\N	completed	3
26059	9	340.00	7	2025-04-25 06:24:47.807946	2025-04-25 06:50:47.807946	\N	completed	1
26060	9	700.00	4	2025-04-25 18:16:47.807946	2025-04-25 19:02:47.807946	\N	completed	8
26061	14	525.00	4	2025-04-25 13:17:47.807946	2025-04-25 13:40:47.807946	\N	completed	8
26062	12	300.00	9	2025-04-25 14:28:47.807946	2025-04-25 15:06:47.807946	\N	completed	34
26063	28	495.00	8	2025-04-25 10:18:47.807946	2025-04-25 10:52:47.807946	\N	completed	34
26064	10	750.00	5	2025-04-25 16:06:47.807946	2025-04-25 16:42:47.807946	\N	completed	10
26065	12	255.00	8	2025-04-25 19:00:47.807946	2025-04-25 19:40:47.807946	\N	completed	32
26066	11	580.00	8	2025-04-25 22:10:47.807946	2025-04-25 22:40:47.807946	\N	completed	36
26067	2	825.00	6	2025-04-25 07:41:47.807946	2025-04-25 08:21:47.807946	\N	completed	6
26068	28	420.00	4	2025-04-25 13:16:47.807946	2025-04-25 13:55:47.807946	\N	completed	10
26069	15	375.00	9	2025-04-25 10:18:47.807946	2025-04-25 11:00:47.807946	\N	completed	3
26070	14	390.00	8	2025-04-25 14:33:47.807946	2025-04-25 15:21:47.807946	\N	completed	10
26071	16	285.00	4	2025-04-25 10:40:47.807946	2025-04-25 11:10:47.807946	\N	completed	8
26072	2	405.00	6	2025-04-25 13:13:47.807946	2025-04-25 13:58:47.807946	\N	completed	6
26073	30	345.00	7	2025-04-25 11:00:47.807946	2025-04-25 11:36:47.807946	\N	completed	1
26074	8	510.00	8	2025-04-25 10:28:47.807946	2025-04-25 11:11:47.807946	\N	completed	34
26075	8	575.00	4	2025-04-25 18:15:47.807946	2025-04-25 19:00:47.807946	\N	completed	9
26076	30	400.00	8	2025-04-25 06:57:47.807946	2025-04-25 07:19:47.807946	\N	completed	3
26077	7	650.00	4	2025-04-25 18:19:47.807946	2025-04-25 18:53:47.807946	\N	completed	11
26078	10	500.00	9	2025-04-25 05:31:47.807946	2025-04-25 06:14:47.807946	\N	completed	36
26079	8	495.00	9	2025-04-25 14:45:47.807946	2025-04-25 15:28:47.807946	\N	completed	3
26080	10	750.00	9	2025-04-26 16:17:47.807946	2025-04-26 17:00:47.807946	\N	completed	36
26081	30	875.00	4	2025-04-26 08:02:47.807946	2025-04-26 08:26:47.807946	\N	completed	34
26082	15	340.00	9	2025-04-26 06:52:47.807946	2025-04-26 07:26:47.807946	\N	completed	32
26083	8	320.00	9	2025-04-26 20:34:47.807946	2025-04-26 21:24:47.807946	\N	completed	11
26084	7	875.00	4	2025-04-26 07:49:47.807946	2025-04-26 08:32:47.807946	\N	completed	9
26085	9	390.00	5	2025-04-26 09:00:47.807946	2025-04-26 09:49:47.807946	\N	completed	34
26086	2	875.00	5	2025-04-26 18:50:47.807946	2025-04-26 19:36:47.807946	\N	completed	10
26087	14	650.00	7	2025-04-26 18:40:47.807946	2025-04-26 19:00:47.807946	\N	completed	9
26088	28	850.00	6	2025-04-26 08:41:47.807946	2025-04-26 09:08:47.807946	\N	completed	8
26089	16	330.00	8	2025-04-26 14:10:47.807946	2025-04-26 14:51:47.807946	\N	completed	32
26090	16	440.00	7	2025-04-26 06:25:47.807946	2025-04-26 06:51:47.807946	\N	completed	6
26091	9	345.00	8	2025-04-26 15:37:47.807946	2025-04-26 16:00:47.807946	\N	completed	1
26092	7	440.00	7	2025-04-26 06:59:47.807946	2025-04-26 07:26:47.807946	\N	completed	34
26093	14	280.00	9	2025-04-26 06:41:47.807946	2025-04-26 07:14:47.807946	\N	completed	36
26094	2	360.00	9	2025-04-26 12:21:47.807946	2025-04-26 12:50:47.807946	\N	completed	36
26095	11	320.00	8	2025-04-26 21:51:47.807946	2025-04-26 22:21:47.807946	\N	completed	10
26096	7	360.00	5	2025-04-26 05:33:47.807946	2025-04-26 06:20:47.807946	\N	completed	32
26097	28	405.00	4	2025-04-26 09:06:47.807946	2025-04-26 09:51:47.807946	\N	completed	34
26098	30	390.00	9	2025-04-26 12:48:47.807946	2025-04-26 13:22:47.807946	\N	completed	6
26099	28	330.00	6	2025-04-26 14:45:47.807946	2025-04-26 15:30:47.807946	\N	completed	11
26100	8	465.00	8	2025-04-26 12:39:47.807946	2025-04-26 13:16:47.807946	\N	completed	1
26101	15	875.00	4	2025-04-26 18:35:47.807946	2025-04-26 19:19:47.807946	\N	completed	10
26102	16	285.00	7	2025-04-26 12:01:47.807946	2025-04-26 12:29:47.807946	\N	completed	32
26103	8	285.00	5	2025-04-27 15:53:47.807946	2025-04-27 16:36:47.807946	\N	completed	9
26104	12	360.00	9	2025-04-27 13:54:47.807946	2025-04-27 14:20:47.807946	\N	completed	9
26105	2	300.00	7	2025-04-27 14:02:47.807946	2025-04-27 14:43:47.807946	\N	completed	10
26106	8	345.00	8	2025-04-27 19:32:47.807946	2025-04-27 19:54:47.807946	\N	completed	11
26107	9	280.00	8	2025-04-27 06:34:47.807946	2025-04-27 07:06:47.807946	\N	completed	1
26108	10	650.00	4	2025-04-27 08:44:47.807946	2025-04-27 09:12:47.807946	\N	completed	6
26109	10	510.00	6	2025-04-27 12:25:47.807946	2025-04-27 12:59:47.807946	\N	completed	8
26110	9	345.00	4	2025-04-27 19:29:47.807946	2025-04-27 19:50:47.807946	\N	completed	34
26111	28	405.00	7	2025-04-27 09:04:47.807946	2025-04-27 09:52:47.807946	\N	completed	1
26112	7	775.00	9	2025-04-27 07:03:47.807946	2025-04-27 07:28:47.807946	\N	completed	6
26113	16	500.00	6	2025-04-27 21:21:47.807946	2025-04-27 21:43:47.807946	\N	completed	34
26114	10	315.00	6	2025-04-27 10:20:47.807946	2025-04-27 11:09:47.807946	\N	completed	1
26115	11	500.00	7	2025-04-27 20:02:47.807946	2025-04-27 20:41:47.807946	\N	completed	11
26116	10	500.00	9	2025-04-27 05:36:47.807946	2025-04-27 06:08:47.807946	\N	completed	8
26117	15	345.00	4	2025-04-27 10:13:47.807946	2025-04-27 10:55:47.807946	\N	completed	10
26118	30	480.00	5	2025-04-27 10:27:47.807946	2025-04-27 11:13:47.807946	\N	completed	32
26119	15	1025.00	8	2025-04-27 16:46:47.807946	2025-04-27 17:21:47.807946	\N	completed	11
26120	10	450.00	9	2025-04-27 09:10:47.807946	2025-04-27 09:41:47.807946	\N	completed	32
26121	2	875.00	6	2025-04-27 08:12:47.807946	2025-04-27 08:35:47.807946	\N	completed	1
26122	2	420.00	8	2025-04-27 20:10:47.807946	2025-04-27 20:54:47.807946	\N	completed	32
26123	14	625.00	4	2025-04-27 07:44:47.807946	2025-04-27 08:06:47.807946	\N	completed	10
26124	11	460.00	7	2025-04-28 21:21:47.807946	2025-04-28 21:56:47.807946	\N	completed	10
26125	15	875.00	9	2025-04-28 07:37:47.807946	2025-04-28 08:03:47.807946	\N	completed	32
26126	11	925.00	4	2025-04-28 07:38:47.807946	2025-04-28 08:15:47.807946	\N	completed	3
26127	28	825.00	5	2025-04-28 17:49:47.807946	2025-04-28 18:18:47.807946	\N	completed	36
26128	14	330.00	9	2025-04-28 10:15:47.807946	2025-04-28 10:41:47.807946	\N	completed	1
26129	9	700.00	9	2025-04-28 16:55:47.807946	2025-04-28 17:16:47.807946	\N	completed	9
26130	14	330.00	8	2025-04-28 10:10:47.807946	2025-04-28 10:52:47.807946	\N	completed	9
26131	10	320.00	6	2025-04-28 06:19:47.807946	2025-04-28 07:09:47.807946	\N	completed	36
26132	12	875.00	7	2025-04-28 07:06:47.807946	2025-04-28 07:39:47.807946	\N	completed	6
26133	14	400.00	9	2025-04-28 20:42:47.807946	2025-04-28 21:26:47.807946	\N	completed	6
26134	11	285.00	7	2025-04-28 19:00:47.807946	2025-04-28 19:49:47.807946	\N	completed	32
26135	8	525.00	6	2025-04-28 15:46:47.807946	2025-04-28 16:06:47.807946	\N	completed	11
26136	8	510.00	4	2025-04-28 11:23:47.807946	2025-04-28 11:59:47.807946	\N	completed	10
26137	15	550.00	6	2025-04-28 16:02:47.807946	2025-04-28 16:50:47.807946	\N	completed	9
26138	8	440.00	7	2025-04-28 06:22:47.807946	2025-04-28 06:42:47.807946	\N	completed	11
26139	10	580.00	6	2025-04-29 20:35:47.807946	2025-04-29 21:18:47.807946	\N	completed	34
26140	15	300.00	6	2025-04-29 11:25:47.807946	2025-04-29 12:11:47.807946	\N	completed	6
26141	7	320.00	4	2025-04-29 21:39:47.807946	2025-04-29 21:59:47.807946	\N	completed	6
26142	7	1000.00	9	2025-04-29 16:47:47.807946	2025-04-29 17:14:47.807946	\N	completed	10
26143	2	330.00	5	2025-04-29 12:58:47.807946	2025-04-29 13:40:47.807946	\N	completed	9
26144	28	285.00	4	2025-04-29 15:44:47.807946	2025-04-29 16:14:47.807946	\N	completed	36
26145	11	540.00	6	2025-04-29 22:54:47.807946	2025-04-29 23:40:47.807946	\N	completed	11
26146	2	420.00	4	2025-04-29 13:52:47.807946	2025-04-29 14:15:47.807946	\N	completed	11
26147	10	320.00	6	2025-04-29 05:20:47.807946	2025-04-29 05:44:47.807946	\N	completed	10
26148	7	525.00	8	2025-04-29 11:47:47.807946	2025-04-29 12:27:47.807946	\N	completed	32
26149	15	625.00	4	2025-04-29 17:15:47.807946	2025-04-29 18:02:47.807946	\N	completed	9
26150	11	375.00	7	2025-04-29 13:41:47.807946	2025-04-29 14:17:47.807946	\N	completed	8
26151	7	1000.00	6	2025-04-29 17:02:47.807946	2025-04-29 17:29:47.807946	\N	completed	8
26152	12	300.00	7	2025-04-29 06:29:47.807946	2025-04-29 07:11:47.807946	\N	completed	32
26153	10	300.00	6	2025-04-29 22:57:47.807946	2025-04-29 23:20:47.807946	\N	completed	36
26154	9	380.00	8	2025-04-29 05:23:47.807946	2025-04-29 05:50:47.807946	\N	completed	34
26155	30	360.00	9	2025-04-29 22:21:47.807946	2025-04-29 22:59:47.807946	\N	completed	32
26156	10	280.00	6	2025-04-29 06:55:47.807946	2025-04-29 07:32:47.807946	\N	completed	1
26157	11	750.00	9	2025-04-29 17:04:47.807946	2025-04-29 17:54:47.807946	\N	completed	9
26158	15	950.00	7	2025-04-29 07:20:47.807946	2025-04-29 07:52:47.807946	\N	completed	6
26159	9	375.00	7	2025-04-29 09:54:47.807946	2025-04-29 10:23:47.807946	\N	completed	32
26160	7	375.00	9	2025-04-29 11:23:47.807946	2025-04-29 11:50:47.807946	\N	completed	32
26161	9	360.00	9	2025-04-29 19:25:47.807946	2025-04-29 19:58:47.807946	\N	completed	3
26162	28	255.00	5	2025-04-30 19:35:47.807946	2025-04-30 20:12:47.807946	\N	completed	1
26163	16	700.00	7	2025-04-30 17:53:47.807946	2025-04-30 18:41:47.807946	\N	completed	1
26164	30	315.00	4	2025-04-30 15:08:47.807946	2025-04-30 15:58:47.807946	\N	completed	1
26165	2	495.00	6	2025-04-30 12:10:47.807946	2025-04-30 12:42:47.807946	\N	completed	6
26166	11	270.00	5	2025-04-30 11:36:47.807946	2025-04-30 12:26:47.807946	\N	completed	11
26167	28	375.00	4	2025-04-30 12:54:47.807946	2025-04-30 13:36:47.807946	\N	completed	8
26168	15	375.00	9	2025-04-30 11:14:47.807946	2025-04-30 11:36:47.807946	\N	completed	6
26169	7	400.00	7	2025-04-30 21:59:47.807946	2025-04-30 22:45:47.807946	\N	completed	8
26170	28	435.00	9	2025-04-30 10:52:47.807946	2025-04-30 11:15:47.807946	\N	completed	6
26171	10	315.00	7	2025-04-30 14:16:47.807946	2025-04-30 15:06:47.807946	\N	completed	32
26172	30	560.00	9	2025-04-30 21:20:47.807946	2025-04-30 21:45:47.807946	\N	completed	8
26173	8	390.00	9	2025-04-30 19:23:47.807946	2025-04-30 19:52:47.807946	\N	completed	6
26174	16	500.00	8	2025-04-30 21:34:47.807946	2025-04-30 22:08:47.807946	\N	completed	8
26175	30	775.00	7	2025-04-30 18:56:47.807946	2025-04-30 19:31:47.807946	\N	completed	1
26176	7	440.00	4	2025-04-30 06:12:47.807946	2025-04-30 06:52:47.807946	\N	completed	36
26177	30	500.00	6	2025-04-30 05:55:47.807946	2025-04-30 06:36:47.807946	\N	completed	36
26178	16	340.00	6	2025-04-30 05:35:47.807946	2025-04-30 05:57:47.807946	\N	completed	6
26179	14	315.00	8	2025-04-30 11:55:47.807946	2025-04-30 12:43:47.807946	\N	completed	34
26180	16	400.00	6	2025-04-30 21:02:47.807946	2025-04-30 21:38:47.807946	\N	completed	1
26181	12	260.00	4	2025-04-30 05:43:47.807946	2025-04-30 06:04:47.807946	\N	completed	11
26182	7	480.00	6	2025-04-30 11:02:47.807946	2025-04-30 11:41:47.807946	\N	completed	34
26183	12	400.00	9	2025-05-01 22:33:47.807946	2025-05-01 23:19:47.807946	\N	completed	36
26184	7	330.00	7	2025-05-01 11:23:47.807946	2025-05-01 11:56:47.807946	\N	completed	32
26185	14	900.00	7	2025-05-01 16:47:47.807946	2025-05-01 17:10:47.807946	\N	completed	1
26186	8	390.00	4	2025-05-01 14:01:47.807946	2025-05-01 14:34:47.807946	\N	completed	1
26187	10	480.00	8	2025-05-01 11:43:47.807946	2025-05-01 12:31:47.807946	\N	completed	9
26188	8	360.00	6	2025-05-01 06:54:47.807946	2025-05-01 07:41:47.807946	\N	completed	8
26189	12	420.00	5	2025-05-01 20:47:47.807946	2025-05-01 21:07:47.807946	\N	completed	9
26190	14	340.00	7	2025-05-01 06:48:47.807946	2025-05-01 07:24:47.807946	\N	completed	11
26191	8	375.00	6	2025-05-01 15:38:47.807946	2025-05-01 16:18:47.807946	\N	completed	11
26192	2	520.00	4	2025-05-01 20:28:47.807946	2025-05-01 20:57:47.807946	\N	completed	9
26193	11	450.00	5	2025-05-01 19:47:47.807946	2025-05-01 20:32:47.807946	\N	completed	9
26194	15	875.00	5	2025-05-01 17:10:47.807946	2025-05-01 17:49:47.807946	\N	completed	1
26195	16	950.00	4	2025-05-01 07:10:47.807946	2025-05-01 07:47:47.807946	\N	completed	8
26196	8	550.00	4	2025-05-01 18:23:47.807946	2025-05-01 19:11:47.807946	\N	completed	32
26197	14	255.00	8	2025-05-01 19:31:47.807946	2025-05-01 20:12:47.807946	\N	completed	3
26198	11	525.00	6	2025-05-01 14:03:47.807946	2025-05-01 14:24:47.807946	\N	completed	6
26199	28	380.00	7	2025-05-01 06:38:47.807946	2025-05-01 07:26:47.807946	\N	completed	3
26200	28	520.00	5	2025-05-01 20:12:47.807946	2025-05-01 20:46:47.807946	\N	completed	8
26201	16	360.00	8	2025-05-01 06:44:47.807946	2025-05-01 07:27:47.807946	\N	completed	8
26202	7	510.00	9	2025-05-01 15:00:47.807946	2025-05-01 15:44:47.807946	\N	completed	6
26203	12	340.00	6	2025-05-01 21:46:47.807946	2025-05-01 22:16:47.807946	\N	completed	8
26204	16	1000.00	5	2025-05-01 08:45:47.807946	2025-05-01 09:21:47.807946	\N	completed	1
26205	10	320.00	8	2025-05-02 06:41:47.807946	2025-05-02 07:20:47.807946	\N	completed	9
26206	7	925.00	9	2025-05-02 08:11:47.807946	2025-05-02 08:52:47.807946	\N	completed	10
26207	14	510.00	6	2025-05-02 12:25:47.807946	2025-05-02 12:51:47.807946	\N	completed	8
26208	12	270.00	7	2025-05-02 12:22:47.807946	2025-05-02 12:44:47.807946	\N	completed	8
26209	11	480.00	9	2025-05-02 11:52:47.807946	2025-05-02 12:22:47.807946	\N	completed	11
26210	8	950.00	6	2025-05-02 17:48:47.807946	2025-05-02 18:29:47.807946	\N	completed	9
26211	8	360.00	5	2025-05-02 14:19:47.807946	2025-05-02 14:48:47.807946	\N	completed	9
26212	9	360.00	9	2025-05-02 15:19:47.807946	2025-05-02 16:06:47.807946	\N	completed	36
26213	2	465.00	4	2025-05-02 10:13:47.807946	2025-05-02 10:51:47.807946	\N	completed	34
26214	30	750.00	9	2025-05-02 07:51:47.807946	2025-05-02 08:34:47.807946	\N	completed	10
26215	30	465.00	8	2025-05-02 12:33:47.807946	2025-05-02 13:22:47.807946	\N	completed	6
26216	14	925.00	6	2025-05-02 08:38:47.807946	2025-05-02 09:16:47.807946	\N	completed	34
26217	12	1000.00	8	2025-05-02 18:44:47.807946	2025-05-02 19:25:47.807946	\N	completed	8
26218	2	345.00	6	2025-05-02 09:15:47.807946	2025-05-02 09:54:47.807946	\N	completed	6
26219	8	400.00	6	2025-05-02 21:28:47.807946	2025-05-02 21:59:47.807946	\N	completed	9
26220	2	460.00	6	2025-05-02 05:46:47.807946	2025-05-02 06:13:47.807946	\N	completed	1
26221	28	975.00	6	2025-05-02 18:47:47.807946	2025-05-02 19:22:47.807946	\N	completed	6
26222	2	390.00	5	2025-05-02 19:24:47.807946	2025-05-02 20:13:47.807946	\N	completed	11
26223	11	315.00	5	2025-05-02 11:50:47.807946	2025-05-02 12:17:47.807946	\N	completed	9
26224	8	330.00	6	2025-05-02 10:55:47.807946	2025-05-02 11:30:47.807946	\N	completed	11
26225	8	500.00	6	2025-05-02 05:55:47.807946	2025-05-02 06:28:47.807946	\N	completed	3
26226	14	525.00	9	2025-05-02 15:50:47.807946	2025-05-02 16:39:47.807946	\N	completed	36
26227	14	435.00	4	2025-05-02 12:55:47.807946	2025-05-02 13:32:47.807946	\N	completed	34
26228	10	480.00	6	2025-05-02 15:37:47.807946	2025-05-02 16:14:47.807946	\N	completed	3
26229	10	950.00	6	2025-05-02 08:35:47.807946	2025-05-02 08:57:47.807946	\N	completed	1
26230	11	420.00	4	2025-05-03 21:09:47.807946	2025-05-03 21:59:47.807946	\N	completed	10
26231	12	925.00	6	2025-05-03 07:55:47.807946	2025-05-03 08:17:47.807946	\N	completed	6
26232	15	600.00	8	2025-05-03 22:30:47.807946	2025-05-03 22:55:47.807946	\N	completed	34
26233	9	285.00	9	2025-05-03 19:03:47.807946	2025-05-03 19:42:47.807946	\N	completed	32
26234	7	600.00	5	2025-05-03 21:28:47.807946	2025-05-03 22:01:47.807946	\N	completed	9
26235	12	560.00	6	2025-05-03 22:45:47.807946	2025-05-03 23:35:47.807946	\N	completed	1
26236	28	900.00	8	2025-05-03 08:37:47.807946	2025-05-03 09:06:47.807946	\N	completed	32
26237	12	340.00	7	2025-05-03 20:33:47.807946	2025-05-03 21:22:47.807946	\N	completed	9
26238	7	975.00	5	2025-05-03 17:11:47.807946	2025-05-03 17:35:47.807946	\N	completed	11
26239	16	675.00	8	2025-05-03 07:51:47.807946	2025-05-03 08:37:47.807946	\N	completed	6
26240	11	450.00	4	2025-05-03 14:45:47.807946	2025-05-03 15:31:47.807946	\N	completed	10
26241	9	450.00	8	2025-05-03 12:15:47.807946	2025-05-03 12:55:47.807946	\N	completed	32
26242	16	405.00	9	2025-05-03 09:53:47.807946	2025-05-03 10:32:47.807946	\N	completed	6
26243	14	480.00	9	2025-05-03 09:01:47.807946	2025-05-03 09:23:47.807946	\N	completed	32
26244	2	405.00	5	2025-05-03 19:20:47.807946	2025-05-03 20:00:47.807946	\N	completed	10
26245	9	270.00	4	2025-05-03 13:17:47.807946	2025-05-03 13:54:47.807946	\N	completed	11
26246	28	340.00	7	2025-05-03 21:00:47.807946	2025-05-03 21:26:47.807946	\N	completed	8
26247	15	315.00	4	2025-05-03 09:44:47.807946	2025-05-03 10:30:47.807946	\N	completed	3
26248	15	925.00	9	2025-05-03 16:52:47.807946	2025-05-03 17:34:47.807946	\N	completed	9
26249	16	480.00	6	2025-05-03 13:24:47.807946	2025-05-03 14:10:47.807946	\N	completed	9
26250	30	825.00	8	2025-05-03 18:56:47.807946	2025-05-03 19:46:47.807946	\N	completed	11
26251	28	875.00	9	2025-05-04 16:57:47.807946	2025-05-04 17:28:47.807946	\N	completed	8
26252	16	975.00	7	2025-05-04 18:49:47.807946	2025-05-04 19:28:47.807946	\N	completed	1
26253	11	270.00	9	2025-05-04 19:02:47.807946	2025-05-04 19:45:47.807946	\N	completed	8
26254	15	600.00	5	2025-05-04 21:15:47.807946	2025-05-04 22:04:47.807946	\N	completed	11
26255	28	675.00	9	2025-05-04 08:45:47.807946	2025-05-04 09:26:47.807946	\N	completed	36
26256	16	510.00	9	2025-05-04 13:56:47.807946	2025-05-04 14:39:47.807946	\N	completed	3
26257	10	330.00	4	2025-05-04 12:34:47.807946	2025-05-04 13:00:47.807946	\N	completed	8
26258	14	390.00	7	2025-05-04 14:30:47.807946	2025-05-04 14:59:47.807946	\N	completed	34
26259	10	375.00	4	2025-05-04 15:44:47.807946	2025-05-04 16:08:47.807946	\N	completed	11
26260	12	420.00	8	2025-05-04 06:10:47.807946	2025-05-04 06:38:47.807946	\N	completed	11
26261	16	575.00	8	2025-05-04 08:51:47.807946	2025-05-04 09:24:47.807946	\N	completed	36
26262	2	285.00	7	2025-05-04 11:19:47.807946	2025-05-04 11:46:47.807946	\N	completed	34
26263	16	510.00	4	2025-05-04 13:13:47.807946	2025-05-04 14:00:47.807946	\N	completed	1
26264	7	240.00	5	2025-05-04 19:34:47.807946	2025-05-04 20:19:47.807946	\N	completed	1
26265	11	440.00	8	2025-05-04 06:01:47.807946	2025-05-04 06:22:47.807946	\N	completed	10
26266	7	440.00	7	2025-05-04 20:08:47.807946	2025-05-04 20:41:47.807946	\N	completed	1
26267	7	700.00	8	2025-05-04 17:44:47.807946	2025-05-04 18:14:47.807946	\N	completed	32
26268	2	375.00	6	2025-05-04 12:09:47.807946	2025-05-04 12:33:47.807946	\N	completed	9
26269	12	775.00	5	2025-05-04 17:36:47.807946	2025-05-04 18:05:47.807946	\N	completed	9
26270	7	435.00	8	2025-05-04 09:45:47.807946	2025-05-04 10:14:47.807946	\N	completed	10
26271	30	480.00	6	2025-05-05 06:53:47.807946	2025-05-05 07:37:47.807946	\N	completed	34
26272	12	300.00	9	2025-05-05 11:58:47.807946	2025-05-05 12:39:47.807946	\N	completed	34
26273	2	420.00	9	2025-05-05 11:48:47.807946	2025-05-05 12:17:47.807946	\N	completed	10
26274	9	480.00	8	2025-05-05 22:01:47.807946	2025-05-05 22:29:47.807946	\N	completed	36
26275	30	850.00	6	2025-05-05 16:10:47.807946	2025-05-05 16:40:47.807946	\N	completed	11
26276	11	600.00	8	2025-05-05 20:04:47.807946	2025-05-05 20:34:47.807946	\N	completed	36
26277	10	1025.00	4	2025-05-05 07:06:47.807946	2025-05-05 07:36:47.807946	\N	completed	9
26278	9	510.00	8	2025-05-05 11:01:47.807946	2025-05-05 11:27:47.807946	\N	completed	11
26279	7	460.00	5	2025-05-05 05:34:47.807946	2025-05-05 06:08:47.807946	\N	completed	11
26280	2	330.00	7	2025-05-05 11:10:47.807946	2025-05-05 11:30:47.807946	\N	completed	11
26281	8	420.00	5	2025-05-05 20:54:47.807946	2025-05-05 21:41:47.807946	\N	completed	11
26282	12	480.00	9	2025-05-05 12:51:47.807946	2025-05-05 13:31:47.807946	\N	completed	10
26283	16	435.00	7	2025-05-05 15:19:47.807946	2025-05-05 15:56:47.807946	\N	completed	36
26284	28	300.00	6	2025-05-05 05:27:47.807946	2025-05-05 05:47:47.807946	\N	completed	36
26285	14	525.00	4	2025-05-05 18:59:47.807946	2025-05-05 19:43:47.807946	\N	completed	32
26286	28	340.00	7	2025-05-05 21:19:47.807946	2025-05-05 21:54:47.807946	\N	completed	36
26287	28	525.00	8	2025-05-05 07:12:47.807946	2025-05-05 08:01:47.807946	\N	completed	34
26288	14	320.00	9	2025-05-05 05:31:47.807946	2025-05-05 06:05:47.807946	\N	completed	3
26289	2	800.00	6	2025-05-05 18:58:47.807946	2025-05-05 19:28:47.807946	\N	completed	6
26290	8	900.00	9	2025-05-06 08:01:47.807946	2025-05-06 08:51:47.807946	\N	completed	10
26291	15	975.00	5	2025-05-06 16:58:47.807946	2025-05-06 17:18:47.807946	\N	completed	10
26292	16	525.00	8	2025-05-06 14:44:47.807946	2025-05-06 15:14:47.807946	\N	completed	9
26293	16	360.00	9	2025-05-06 13:03:47.807946	2025-05-06 13:33:47.807946	\N	completed	34
26294	14	850.00	6	2025-05-06 17:35:47.807946	2025-05-06 18:06:47.807946	\N	completed	1
26295	16	480.00	9	2025-05-06 15:40:47.807946	2025-05-06 16:13:47.807946	\N	completed	11
26296	8	360.00	7	2025-05-06 13:53:47.807946	2025-05-06 14:21:47.807946	\N	completed	11
26297	8	525.00	8	2025-05-06 18:52:47.807946	2025-05-06 19:17:47.807946	\N	completed	9
26298	7	510.00	6	2025-05-06 10:52:47.807946	2025-05-06 11:24:47.807946	\N	completed	11
26299	8	340.00	6	2025-05-06 22:13:47.807946	2025-05-06 22:45:47.807946	\N	completed	3
26300	7	380.00	7	2025-05-06 22:18:47.807946	2025-05-06 22:56:47.807946	\N	completed	9
26301	10	390.00	7	2025-05-06 13:23:47.807946	2025-05-06 13:57:47.807946	\N	completed	34
26302	28	775.00	9	2025-05-06 08:43:47.807946	2025-05-06 09:06:47.807946	\N	completed	9
26303	15	400.00	6	2025-05-06 20:07:47.807946	2025-05-06 20:56:47.807946	\N	completed	10
26304	16	480.00	8	2025-05-06 09:17:47.807946	2025-05-06 09:48:47.807946	\N	completed	6
26305	16	1000.00	8	2025-05-06 08:21:47.807946	2025-05-06 08:47:47.807946	\N	completed	8
26306	11	360.00	9	2025-05-06 13:56:47.807946	2025-05-06 14:30:47.807946	\N	completed	36
26307	2	875.00	9	2025-05-06 08:00:47.807946	2025-05-06 08:40:47.807946	\N	completed	34
26308	16	300.00	4	2025-05-07 09:48:47.807946	2025-05-07 10:35:47.807946	\N	completed	1
26309	15	450.00	5	2025-05-07 14:32:47.807946	2025-05-07 15:03:47.807946	\N	completed	9
26310	12	435.00	8	2025-05-07 19:54:47.807946	2025-05-07 20:43:47.807946	\N	completed	36
26311	12	285.00	9	2025-05-07 12:39:47.807946	2025-05-07 13:28:47.807946	\N	completed	9
26312	8	280.00	8	2025-05-07 06:54:47.807946	2025-05-07 07:33:47.807946	\N	completed	3
26313	28	750.00	5	2025-05-07 07:19:47.807946	2025-05-07 08:01:47.807946	\N	completed	10
26314	15	560.00	7	2025-05-07 20:17:47.807946	2025-05-07 20:59:47.807946	\N	completed	11
26315	8	950.00	6	2025-05-07 07:53:47.807946	2025-05-07 08:14:47.807946	\N	completed	3
26316	8	300.00	9	2025-05-07 13:53:47.807946	2025-05-07 14:21:47.807946	\N	completed	8
26317	2	315.00	9	2025-05-07 12:37:47.807946	2025-05-07 12:57:47.807946	\N	completed	3
26318	9	340.00	7	2025-05-07 06:50:47.807946	2025-05-07 07:25:47.807946	\N	completed	32
26319	12	480.00	9	2025-05-07 05:25:47.807946	2025-05-07 05:47:47.807946	\N	completed	9
26320	10	300.00	7	2025-05-07 14:30:47.807946	2025-05-07 15:15:47.807946	\N	completed	9
26321	8	315.00	6	2025-05-07 15:24:47.807946	2025-05-07 15:59:47.807946	\N	completed	1
26322	8	345.00	9	2025-05-07 10:17:47.807946	2025-05-07 10:59:47.807946	\N	completed	6
26323	30	975.00	6	2025-05-07 08:08:47.807946	2025-05-07 08:32:47.807946	\N	completed	34
26324	30	340.00	8	2025-05-07 05:06:47.807946	2025-05-07 05:33:47.807946	\N	completed	8
26325	15	340.00	5	2025-05-07 21:33:47.807946	2025-05-07 22:06:47.807946	\N	completed	6
26326	2	500.00	8	2025-05-07 20:36:47.807946	2025-05-07 21:22:47.807946	\N	completed	11
26327	11	600.00	5	2025-05-07 07:17:47.807946	2025-05-07 08:07:47.807946	\N	completed	11
26328	14	900.00	6	2025-05-07 17:25:47.807946	2025-05-07 17:57:47.807946	\N	completed	8
26329	30	525.00	6	2025-05-07 09:28:47.807946	2025-05-07 09:48:47.807946	\N	completed	1
26330	15	405.00	9	2025-05-07 09:08:47.807946	2025-05-07 09:51:47.807946	\N	completed	8
26331	12	420.00	6	2025-05-07 22:59:47.807946	2025-05-07 23:22:47.807946	\N	completed	1
26332	30	405.00	9	2025-05-07 15:14:47.807946	2025-05-07 15:53:47.807946	\N	completed	1
26333	14	750.00	5	2025-05-07 07:46:47.807946	2025-05-07 08:22:47.807946	\N	completed	3
26334	2	380.00	4	2025-05-07 06:12:47.807946	2025-05-07 06:32:47.807946	\N	completed	32
26335	14	480.00	4	2025-05-07 15:20:47.807946	2025-05-07 15:57:47.807946	\N	completed	32
26336	11	750.00	8	2025-05-07 17:24:47.807946	2025-05-07 18:05:47.807946	\N	completed	10
26337	8	345.00	7	2025-05-07 13:23:47.807946	2025-05-07 13:52:47.807946	\N	completed	1
26338	8	420.00	8	2025-05-08 09:43:47.807946	2025-05-08 10:23:47.807946	\N	completed	11
26339	9	400.00	5	2025-05-08 06:10:47.807946	2025-05-08 06:57:47.807946	\N	completed	36
26340	16	340.00	9	2025-05-08 06:06:47.807946	2025-05-08 06:39:47.807946	\N	completed	36
26341	2	510.00	4	2025-05-08 10:05:47.807946	2025-05-08 10:46:47.807946	\N	completed	32
26342	16	600.00	7	2025-05-08 21:37:47.807946	2025-05-08 22:08:47.807946	\N	completed	1
26343	8	435.00	8	2025-05-08 13:09:47.807946	2025-05-08 13:56:47.807946	\N	completed	6
26344	2	650.00	4	2025-05-08 18:52:47.807946	2025-05-08 19:24:47.807946	\N	completed	8
26345	10	800.00	7	2025-05-08 18:04:47.807946	2025-05-08 18:29:47.807946	\N	completed	6
26346	9	360.00	5	2025-05-08 19:02:47.807946	2025-05-08 19:29:47.807946	\N	completed	32
26347	15	495.00	5	2025-05-08 13:10:47.807946	2025-05-08 13:40:47.807946	\N	completed	3
26348	7	900.00	4	2025-05-08 16:23:47.807946	2025-05-08 16:52:47.807946	\N	completed	8
26349	30	525.00	8	2025-05-08 16:08:47.807946	2025-05-08 16:28:47.807946	\N	completed	9
26350	15	300.00	8	2025-05-08 19:49:47.807946	2025-05-08 20:14:47.807946	\N	completed	1
26351	28	975.00	7	2025-05-08 07:08:47.807946	2025-05-08 07:31:47.807946	\N	completed	9
26352	15	600.00	4	2025-05-08 21:09:47.807946	2025-05-08 21:53:47.807946	\N	completed	32
26353	16	380.00	9	2025-05-08 20:27:47.807946	2025-05-08 21:00:47.807946	\N	completed	9
26354	15	440.00	6	2025-05-08 20:19:47.807946	2025-05-08 21:03:47.807946	\N	completed	8
26355	28	390.00	4	2025-05-08 13:06:47.807946	2025-05-08 13:31:47.807946	\N	completed	1
26356	14	285.00	7	2025-05-08 09:13:47.807946	2025-05-08 09:45:47.807946	\N	completed	9
26357	9	575.00	7	2025-05-08 18:30:47.807946	2025-05-08 19:06:47.807946	\N	completed	32
26358	7	525.00	7	2025-05-08 10:53:47.807946	2025-05-08 11:40:47.807946	\N	completed	9
26359	30	540.00	9	2025-05-09 20:20:47.807946	2025-05-09 20:43:47.807946	\N	completed	9
26360	30	375.00	5	2025-05-09 14:12:47.807946	2025-05-09 14:51:47.807946	\N	completed	6
26361	12	750.00	4	2025-05-09 08:46:47.807946	2025-05-09 09:10:47.807946	\N	completed	3
26362	10	525.00	5	2025-05-09 13:51:47.807946	2025-05-09 14:29:47.807946	\N	completed	10
26363	11	875.00	5	2025-05-09 18:33:47.807946	2025-05-09 19:13:47.807946	\N	completed	1
26364	14	330.00	8	2025-05-09 14:36:47.807946	2025-05-09 15:16:47.807946	\N	completed	10
26365	30	500.00	4	2025-05-09 21:26:47.807946	2025-05-09 22:09:47.807946	\N	completed	3
26366	28	540.00	4	2025-05-09 21:26:47.807946	2025-05-09 21:49:47.807946	\N	completed	6
26367	7	345.00	9	2025-05-09 11:01:47.807946	2025-05-09 11:43:47.807946	\N	completed	32
26368	7	375.00	6	2025-05-09 19:23:47.807946	2025-05-09 19:51:47.807946	\N	completed	1
26369	16	525.00	9	2025-05-09 11:13:47.807946	2025-05-09 12:02:47.807946	\N	completed	11
26370	2	495.00	6	2025-05-09 15:04:47.807946	2025-05-09 15:24:47.807946	\N	completed	34
26371	14	600.00	9	2025-05-09 16:02:47.807946	2025-05-09 16:38:47.807946	\N	completed	36
26372	8	525.00	4	2025-05-09 16:59:47.807946	2025-05-09 17:43:47.807946	\N	completed	11
26373	30	435.00	9	2025-05-09 10:29:47.807946	2025-05-09 11:13:47.807946	\N	completed	32
26374	8	725.00	9	2025-05-09 17:10:47.807946	2025-05-09 17:35:47.807946	\N	completed	3
26375	14	450.00	7	2025-05-09 11:20:47.807946	2025-05-09 11:45:47.807946	\N	completed	32
26376	10	750.00	9	2025-05-09 17:33:47.807946	2025-05-09 17:58:47.807946	\N	completed	10
26377	30	360.00	7	2025-05-09 10:09:47.807946	2025-05-09 10:37:47.807946	\N	completed	10
26378	28	825.00	5	2025-05-09 17:40:47.807946	2025-05-09 18:24:47.807946	\N	completed	1
26379	14	500.00	7	2025-05-09 05:12:47.807946	2025-05-09 05:55:47.807946	\N	completed	10
26380	30	360.00	8	2025-05-09 09:05:47.807946	2025-05-09 09:49:47.807946	\N	completed	3
26381	30	510.00	6	2025-05-09 09:11:47.807946	2025-05-09 09:33:47.807946	\N	completed	6
26382	28	360.00	7	2025-05-09 06:23:47.807946	2025-05-09 06:54:47.807946	\N	completed	34
26383	15	300.00	7	2025-05-09 12:43:47.807946	2025-05-09 13:04:47.807946	\N	completed	3
26384	12	510.00	6	2025-05-09 15:58:47.807946	2025-05-09 16:32:47.807946	\N	completed	32
26385	2	1000.00	7	2025-05-10 07:22:47.807946	2025-05-10 07:45:47.807946	\N	completed	6
26386	12	345.00	5	2025-05-10 15:41:47.807946	2025-05-10 16:17:47.807946	\N	completed	1
26387	12	285.00	5	2025-05-10 09:06:47.807946	2025-05-10 09:43:47.807946	\N	completed	9
26388	11	750.00	9	2025-05-10 17:27:47.807946	2025-05-10 18:15:47.807946	\N	completed	11
26389	2	330.00	6	2025-05-10 19:15:47.807946	2025-05-10 19:54:47.807946	\N	completed	1
26390	11	300.00	4	2025-05-10 12:06:47.807946	2025-05-10 12:29:47.807946	\N	completed	10
26391	2	420.00	6	2025-05-10 20:56:47.807946	2025-05-10 21:34:47.807946	\N	completed	11
26392	9	330.00	4	2025-05-10 15:24:47.807946	2025-05-10 16:11:47.807946	\N	completed	3
26393	14	375.00	4	2025-05-10 10:39:47.807946	2025-05-10 11:22:47.807946	\N	completed	36
26394	30	375.00	8	2025-05-10 13:00:47.807946	2025-05-10 13:48:47.807946	\N	completed	6
26395	10	360.00	7	2025-05-10 15:13:47.807946	2025-05-10 15:41:47.807946	\N	completed	6
26396	14	520.00	6	2025-05-10 21:32:47.807946	2025-05-10 22:05:47.807946	\N	completed	9
26397	15	390.00	4	2025-05-10 12:48:47.807946	2025-05-10 13:35:47.807946	\N	completed	10
26398	16	625.00	4	2025-05-10 16:30:47.807946	2025-05-10 17:17:47.807946	\N	completed	11
26399	12	525.00	8	2025-05-10 08:46:47.807946	2025-05-10 09:26:47.807946	\N	completed	1
26400	15	405.00	6	2025-05-10 10:46:47.807946	2025-05-10 11:31:47.807946	\N	completed	11
26401	16	460.00	7	2025-05-10 05:54:47.807946	2025-05-10 06:22:47.807946	\N	completed	3
26402	12	525.00	8	2025-05-10 16:02:47.807946	2025-05-10 16:38:47.807946	\N	completed	11
26403	2	460.00	9	2025-05-10 22:29:47.807946	2025-05-10 23:01:47.807946	\N	completed	6
26404	10	510.00	7	2025-05-10 13:02:47.807946	2025-05-10 13:39:47.807946	\N	completed	1
26405	2	330.00	6	2025-05-10 19:24:47.807946	2025-05-10 20:14:47.807946	\N	completed	1
26406	16	390.00	8	2025-05-10 09:07:47.807946	2025-05-10 09:43:47.807946	\N	completed	6
26407	14	900.00	7	2025-05-11 17:55:47.807946	2025-05-11 18:33:47.807946	\N	completed	10
26408	15	400.00	5	2025-05-11 06:17:47.807946	2025-05-11 06:41:47.807946	\N	completed	36
26409	2	495.00	9	2025-05-11 09:35:47.807946	2025-05-11 10:19:47.807946	\N	completed	11
26410	30	1025.00	7	2025-05-11 17:27:47.807946	2025-05-11 18:17:47.807946	\N	completed	11
26411	15	480.00	9	2025-05-11 14:44:47.807946	2025-05-11 15:13:47.807946	\N	completed	1
26412	16	340.00	6	2025-05-11 20:25:47.807946	2025-05-11 21:12:47.807946	\N	completed	9
26413	8	625.00	4	2025-05-11 07:02:47.807946	2025-05-11 07:43:47.807946	\N	completed	1
26414	12	1025.00	7	2025-05-11 08:08:47.807946	2025-05-11 08:37:47.807946	\N	completed	9
26415	14	440.00	6	2025-05-11 22:17:47.807946	2025-05-11 23:04:47.807946	\N	completed	34
26416	11	390.00	9	2025-05-11 12:13:47.807946	2025-05-11 12:56:47.807946	\N	completed	6
26417	9	900.00	5	2025-05-11 17:47:47.807946	2025-05-11 18:35:47.807946	\N	completed	8
26418	16	510.00	9	2025-05-11 13:03:47.807946	2025-05-11 13:40:47.807946	\N	completed	1
26419	2	460.00	9	2025-05-11 05:14:47.807946	2025-05-11 06:00:47.807946	\N	completed	8
26420	10	465.00	6	2025-05-11 11:09:47.807946	2025-05-11 11:35:47.807946	\N	completed	1
26421	12	360.00	8	2025-05-11 22:27:47.807946	2025-05-11 23:11:47.807946	\N	completed	9
26422	12	315.00	9	2025-05-11 15:24:47.807946	2025-05-11 15:44:47.807946	\N	completed	36
26423	14	320.00	5	2025-05-11 21:21:47.807946	2025-05-11 21:43:47.807946	\N	completed	11
26424	7	480.00	5	2025-05-11 11:22:47.807946	2025-05-11 12:04:47.807946	\N	completed	9
26425	9	1025.00	9	2025-05-11 17:44:47.807946	2025-05-11 18:07:47.807946	\N	completed	34
26426	8	575.00	9	2025-05-11 07:10:47.807946	2025-05-11 07:57:47.807946	\N	completed	11
26427	12	750.00	9	2025-05-12 17:20:47.807946	2025-05-12 17:46:47.807946	\N	completed	1
26428	7	420.00	6	2025-05-12 05:54:47.807946	2025-05-12 06:37:47.807946	\N	completed	11
26429	2	975.00	6	2025-05-12 17:07:47.807946	2025-05-12 17:38:47.807946	\N	completed	34
26430	16	465.00	5	2025-05-12 11:42:47.807946	2025-05-12 12:05:47.807946	\N	completed	6
26431	28	495.00	7	2025-05-12 10:40:47.807946	2025-05-12 11:00:47.807946	\N	completed	34
26432	12	285.00	4	2025-05-12 09:09:47.807946	2025-05-12 09:29:47.807946	\N	completed	1
26433	16	465.00	9	2025-05-12 12:32:47.807946	2025-05-12 13:17:47.807946	\N	completed	9
26434	30	440.00	8	2025-05-12 06:02:47.807946	2025-05-12 06:38:47.807946	\N	completed	3
26435	15	435.00	8	2025-05-12 09:59:47.807946	2025-05-12 10:48:47.807946	\N	completed	32
26436	14	345.00	8	2025-05-12 15:13:47.807946	2025-05-12 15:33:47.807946	\N	completed	36
26437	7	360.00	5	2025-05-12 19:13:47.807946	2025-05-12 19:42:47.807946	\N	completed	9
26438	8	800.00	6	2025-05-12 17:09:47.807946	2025-05-12 17:31:47.807946	\N	completed	36
26439	14	330.00	7	2025-05-12 12:28:47.807946	2025-05-12 13:17:47.807946	\N	completed	36
26440	15	575.00	6	2025-05-12 08:34:47.807946	2025-05-12 08:59:47.807946	\N	completed	6
26441	15	340.00	5	2025-05-12 05:23:47.807946	2025-05-12 05:56:47.807946	\N	completed	9
26442	30	375.00	8	2025-05-12 15:52:47.807946	2025-05-12 16:41:47.807946	\N	completed	36
26443	28	950.00	7	2025-05-12 18:54:47.807946	2025-05-12 19:35:47.807946	\N	completed	11
26444	12	925.00	6	2025-05-12 08:44:47.807946	2025-05-12 09:21:47.807946	\N	completed	1
26445	8	480.00	4	2025-05-13 15:30:47.807946	2025-05-13 15:59:47.807946	\N	completed	8
26446	2	460.00	6	2025-05-13 20:35:47.807946	2025-05-13 20:55:47.807946	\N	completed	32
26447	8	540.00	5	2025-05-13 22:49:47.807946	2025-05-13 23:12:47.807946	\N	completed	3
26448	12	450.00	6	2025-05-13 10:25:47.807946	2025-05-13 10:50:47.807946	\N	completed	34
26449	28	375.00	9	2025-05-13 14:18:47.807946	2025-05-13 14:44:47.807946	\N	completed	32
26450	15	390.00	9	2025-05-13 09:50:47.807946	2025-05-13 10:37:47.807946	\N	completed	6
26451	16	390.00	7	2025-05-13 14:33:47.807946	2025-05-13 15:05:47.807946	\N	completed	32
26452	8	260.00	7	2025-05-13 05:44:47.807946	2025-05-13 06:08:47.807946	\N	completed	9
26453	2	480.00	6	2025-05-13 11:36:47.807946	2025-05-13 12:18:47.807946	\N	completed	6
26454	7	525.00	6	2025-05-13 15:34:47.807946	2025-05-13 16:11:47.807946	\N	completed	6
26455	9	925.00	5	2025-05-13 17:23:47.807946	2025-05-13 18:07:47.807946	\N	completed	11
26456	16	560.00	5	2025-05-13 22:33:47.807946	2025-05-13 22:58:47.807946	\N	completed	8
26457	10	340.00	9	2025-05-13 06:37:47.807946	2025-05-13 07:23:47.807946	\N	completed	9
26458	8	400.00	9	2025-05-13 22:46:47.807946	2025-05-13 23:30:47.807946	\N	completed	10
26459	12	320.00	4	2025-05-13 20:40:47.807946	2025-05-13 21:26:47.807946	\N	completed	1
26460	11	525.00	4	2025-05-13 10:29:47.807946	2025-05-13 11:07:47.807946	\N	completed	11
26461	28	510.00	6	2025-05-13 15:13:47.807946	2025-05-13 15:45:47.807946	\N	completed	10
26462	16	270.00	5	2025-05-13 15:28:47.807946	2025-05-13 16:02:47.807946	\N	completed	10
26463	15	480.00	7	2025-05-13 11:54:47.807946	2025-05-13 12:29:47.807946	\N	completed	1
26464	28	800.00	9	2025-05-13 17:39:47.807946	2025-05-13 18:24:47.807946	\N	completed	11
26465	12	345.00	7	2025-05-13 13:58:47.807946	2025-05-13 14:46:47.807946	\N	completed	34
26466	28	330.00	5	2025-05-13 12:50:47.807946	2025-05-13 13:38:47.807946	\N	completed	8
26467	16	300.00	9	2025-05-13 12:01:47.807946	2025-05-13 12:38:47.807946	\N	completed	36
26468	11	510.00	9	2025-05-14 12:08:47.807946	2025-05-14 12:49:47.807946	\N	completed	34
26469	8	1000.00	4	2025-05-14 16:41:47.807946	2025-05-14 17:04:47.807946	\N	completed	11
26470	16	260.00	7	2025-05-14 06:28:47.807946	2025-05-14 07:09:47.807946	\N	completed	1
26471	15	580.00	6	2025-05-14 22:05:47.807946	2025-05-14 22:46:47.807946	\N	completed	9
26472	9	330.00	7	2025-05-14 10:17:47.807946	2025-05-14 10:41:47.807946	\N	completed	36
26473	30	625.00	5	2025-05-14 17:30:47.807946	2025-05-14 17:57:47.807946	\N	completed	32
26474	14	435.00	9	2025-05-14 09:54:47.807946	2025-05-14 10:24:47.807946	\N	completed	8
26475	7	315.00	8	2025-05-14 13:50:47.807946	2025-05-14 14:16:47.807946	\N	completed	9
26476	9	315.00	8	2025-05-14 09:33:47.807946	2025-05-14 09:55:47.807946	\N	completed	9
26477	11	420.00	6	2025-05-14 15:07:47.807946	2025-05-14 15:30:47.807946	\N	completed	3
26478	30	650.00	8	2025-05-14 18:27:47.807946	2025-05-14 19:04:47.807946	\N	completed	32
26479	11	300.00	8	2025-05-14 20:50:47.807946	2025-05-14 21:30:47.807946	\N	completed	8
26480	2	520.00	7	2025-05-14 22:50:47.807946	2025-05-14 23:38:47.807946	\N	completed	10
26481	14	420.00	6	2025-05-14 22:58:47.807946	2025-05-14 23:38:47.807946	\N	completed	11
26482	8	320.00	5	2025-05-14 05:23:47.807946	2025-05-14 05:44:47.807946	\N	completed	6
26483	2	625.00	9	2025-05-14 18:58:47.807946	2025-05-14 19:30:47.807946	\N	completed	9
26484	8	1025.00	8	2025-05-14 16:18:47.807946	2025-05-14 16:48:47.807946	\N	completed	9
26485	11	440.00	8	2025-05-14 22:40:47.807946	2025-05-14 23:04:47.807946	\N	completed	8
26486	15	825.00	9	2025-05-14 07:43:47.807946	2025-05-14 08:10:47.807946	\N	completed	6
26487	28	435.00	7	2025-05-14 10:41:47.807946	2025-05-14 11:19:47.807946	\N	completed	36
26488	12	500.00	7	2025-05-14 06:17:47.807946	2025-05-14 06:39:47.807946	\N	completed	34
26489	10	450.00	5	2025-05-14 12:40:47.807946	2025-05-14 13:27:47.807946	\N	completed	8
26490	11	1025.00	8	2025-05-14 07:03:47.807946	2025-05-14 07:34:47.807946	\N	completed	10
26491	12	480.00	9	2025-05-14 05:31:47.807946	2025-05-14 06:18:47.807946	\N	completed	6
26492	2	270.00	6	2025-05-14 10:45:47.807946	2025-05-14 11:16:47.807946	\N	completed	32
26493	16	550.00	6	2025-05-14 08:15:47.807946	2025-05-14 08:53:47.807946	\N	completed	1
26494	12	390.00	9	2025-05-15 19:01:47.807946	2025-05-15 19:50:47.807946	\N	completed	10
26495	12	500.00	6	2025-05-15 05:32:47.807946	2025-05-15 06:11:47.807946	\N	completed	11
26496	7	460.00	9	2025-05-15 22:46:47.807946	2025-05-15 23:12:47.807946	\N	completed	32
26497	14	345.00	9	2025-05-15 14:19:47.807946	2025-05-15 14:54:47.807946	\N	completed	1
26498	10	260.00	6	2025-05-15 05:49:47.807946	2025-05-15 06:34:47.807946	\N	completed	9
26499	8	435.00	5	2025-05-15 14:00:47.807946	2025-05-15 14:49:47.807946	\N	completed	1
26500	14	850.00	9	2025-05-15 08:53:47.807946	2025-05-15 09:39:47.807946	\N	completed	36
26501	14	825.00	8	2025-05-15 17:37:47.807946	2025-05-15 18:12:47.807946	\N	completed	10
26502	16	450.00	7	2025-05-15 10:02:47.807946	2025-05-15 10:45:47.807946	\N	completed	32
26503	15	260.00	9	2025-05-15 05:23:47.807946	2025-05-15 06:13:47.807946	\N	completed	10
26504	15	405.00	8	2025-05-15 09:34:47.807946	2025-05-15 10:08:47.807946	\N	completed	11
26505	16	950.00	9	2025-05-15 16:19:47.807946	2025-05-15 17:05:47.807946	\N	completed	9
26506	28	675.00	5	2025-05-15 18:23:47.807946	2025-05-15 18:49:47.807946	\N	completed	11
26507	16	345.00	9	2025-05-15 10:41:47.807946	2025-05-15 11:31:47.807946	\N	completed	34
26508	9	800.00	4	2025-05-15 08:00:47.807946	2025-05-15 08:49:47.807946	\N	completed	6
26509	8	900.00	8	2025-05-15 08:19:47.807946	2025-05-15 08:57:47.807946	\N	completed	32
26510	14	405.00	6	2025-05-15 19:13:47.807946	2025-05-15 19:51:47.807946	\N	completed	8
26511	14	360.00	9	2025-05-15 20:33:47.807946	2025-05-15 20:59:47.807946	\N	completed	32
26512	16	420.00	8	2025-05-15 09:43:47.807946	2025-05-15 10:23:47.807946	\N	completed	32
26513	12	375.00	4	2025-05-15 12:09:47.807946	2025-05-15 12:55:47.807946	\N	completed	8
26514	9	625.00	7	2025-05-15 18:56:47.807946	2025-05-15 19:20:47.807946	\N	completed	34
26515	16	925.00	7	2025-05-15 08:20:47.807946	2025-05-15 09:06:47.807946	\N	completed	1
26516	12	315.00	8	2025-05-15 13:16:47.807946	2025-05-15 14:01:47.807946	\N	completed	11
26517	16	330.00	8	2025-05-16 19:22:47.807946	2025-05-16 20:07:47.807946	\N	completed	32
26518	2	400.00	8	2025-05-16 20:38:47.807946	2025-05-16 21:12:47.807946	\N	completed	9
26519	11	380.00	7	2025-05-16 21:41:47.807946	2025-05-16 22:25:47.807946	\N	completed	8
26520	30	390.00	9	2025-05-16 10:11:47.807946	2025-05-16 10:49:47.807946	\N	completed	3
26521	11	520.00	5	2025-05-16 22:25:47.807946	2025-05-16 22:45:47.807946	\N	completed	32
26522	15	580.00	5	2025-05-16 20:34:47.807946	2025-05-16 21:02:47.807946	\N	completed	36
26523	15	500.00	6	2025-05-16 22:39:47.807946	2025-05-16 23:04:47.807946	\N	completed	32
26524	7	825.00	5	2025-05-16 16:09:47.807946	2025-05-16 16:30:47.807946	\N	completed	6
26525	16	360.00	6	2025-05-16 11:14:47.807946	2025-05-16 12:00:47.807946	\N	completed	3
26526	2	510.00	7	2025-05-16 14:15:47.807946	2025-05-16 14:43:47.807946	\N	completed	32
26527	2	375.00	9	2025-05-16 15:40:47.807946	2025-05-16 16:13:47.807946	\N	completed	36
26528	12	360.00	5	2025-05-16 20:07:47.807946	2025-05-16 20:43:47.807946	\N	completed	11
26529	14	260.00	6	2025-05-16 06:33:47.807946	2025-05-16 07:15:47.807946	\N	completed	36
26530	12	345.00	5	2025-05-16 19:52:47.807946	2025-05-16 20:22:47.807946	\N	completed	6
26531	16	525.00	9	2025-05-16 07:07:47.807946	2025-05-16 07:53:47.807946	\N	completed	3
26532	10	540.00	8	2025-05-16 21:33:47.807946	2025-05-16 22:08:47.807946	\N	completed	34
26533	8	255.00	9	2025-05-16 19:10:47.807946	2025-05-16 19:58:47.807946	\N	completed	10
26534	30	540.00	5	2025-05-16 22:03:47.807946	2025-05-16 22:29:47.807946	\N	completed	36
26535	28	1000.00	4	2025-05-16 16:36:47.807946	2025-05-16 17:08:47.807946	\N	completed	8
26536	2	450.00	9	2025-05-16 11:51:47.807946	2025-05-16 12:21:47.807946	\N	completed	34
26537	15	420.00	5	2025-05-16 11:57:47.807946	2025-05-16 12:35:47.807946	\N	completed	10
26538	8	420.00	7	2025-05-16 14:23:47.807946	2025-05-16 14:48:47.807946	\N	completed	11
26539	10	480.00	8	2025-05-16 12:37:47.807946	2025-05-16 13:21:47.807946	\N	completed	9
26540	12	300.00	7	2025-05-16 14:06:47.807946	2025-05-16 14:49:47.807946	\N	completed	3
26541	12	480.00	8	2025-05-16 05:58:47.807946	2025-05-16 06:43:47.807946	\N	completed	6
26542	14	775.00	5	2025-05-16 08:57:47.807946	2025-05-16 09:25:47.807946	\N	completed	6
26543	7	440.00	8	2025-05-17 20:03:47.807946	2025-05-17 20:48:47.807946	\N	completed	32
26544	15	875.00	9	2025-05-17 17:56:47.807946	2025-05-17 18:41:47.807946	\N	completed	34
26545	16	405.00	8	2025-05-17 14:07:47.807946	2025-05-17 14:55:47.807946	\N	completed	9
26546	16	775.00	9	2025-05-17 17:40:47.807946	2025-05-17 18:23:47.807946	\N	completed	11
26547	12	480.00	9	2025-05-17 05:57:47.807946	2025-05-17 06:42:47.807946	\N	completed	6
26548	14	380.00	9	2025-05-17 21:02:47.807946	2025-05-17 21:37:47.807946	\N	completed	10
26549	2	450.00	6	2025-05-17 13:53:47.807946	2025-05-17 14:31:47.807946	\N	completed	1
26550	11	405.00	6	2025-05-17 09:25:47.807946	2025-05-17 10:12:47.807946	\N	completed	1
26551	2	375.00	4	2025-05-17 10:31:47.807946	2025-05-17 11:10:47.807946	\N	completed	34
26552	16	300.00	7	2025-05-17 13:42:47.807946	2025-05-17 14:09:47.807946	\N	completed	3
26553	2	330.00	9	2025-05-17 19:25:47.807946	2025-05-17 19:51:47.807946	\N	completed	1
26554	2	300.00	9	2025-05-17 15:40:47.807946	2025-05-17 16:29:47.807946	\N	completed	32
26555	15	270.00	5	2025-05-17 14:14:47.807946	2025-05-17 14:35:47.807946	\N	completed	11
26556	8	600.00	7	2025-05-17 08:30:47.807946	2025-05-17 09:11:47.807946	\N	completed	8
26557	30	495.00	7	2025-05-17 11:00:47.807946	2025-05-17 11:31:47.807946	\N	completed	36
26558	30	330.00	4	2025-05-17 12:07:47.807946	2025-05-17 12:33:47.807946	\N	completed	1
26559	30	750.00	7	2025-05-17 08:34:47.807946	2025-05-17 08:55:47.807946	\N	completed	9
26560	16	550.00	4	2025-05-17 18:50:47.807946	2025-05-17 19:38:47.807946	\N	completed	1
26561	14	435.00	4	2025-05-17 14:01:47.807946	2025-05-17 14:39:47.807946	\N	completed	6
26562	10	340.00	7	2025-05-17 21:19:47.807946	2025-05-17 21:53:47.807946	\N	completed	9
26563	10	300.00	7	2025-05-17 20:13:47.807946	2025-05-17 21:00:47.807946	\N	completed	11
26564	30	450.00	6	2025-05-17 19:07:47.807946	2025-05-17 19:56:47.807946	\N	completed	36
26565	30	520.00	7	2025-05-17 20:49:47.807946	2025-05-17 21:13:47.807946	\N	completed	8
26566	15	450.00	8	2025-05-17 12:38:47.807946	2025-05-17 13:03:47.807946	\N	completed	1
26567	2	390.00	4	2025-05-18 13:43:47.807946	2025-05-18 14:25:47.807946	\N	completed	10
26568	15	450.00	4	2025-05-18 15:46:47.807946	2025-05-18 16:11:47.807946	\N	completed	8
26569	10	580.00	7	2025-05-18 20:46:47.807946	2025-05-18 21:24:47.807946	\N	completed	10
26570	10	540.00	4	2025-05-18 20:04:47.807946	2025-05-18 20:24:47.807946	\N	completed	1
26571	28	480.00	5	2025-05-18 06:31:47.807946	2025-05-18 07:06:47.807946	\N	completed	1
26572	2	360.00	8	2025-05-18 20:51:47.807946	2025-05-18 21:32:47.807946	\N	completed	9
26573	8	300.00	4	2025-05-18 21:01:47.807946	2025-05-18 21:39:47.807946	\N	completed	1
26574	7	380.00	6	2025-05-18 05:04:47.807946	2025-05-18 05:37:47.807946	\N	completed	1
26575	30	450.00	8	2025-05-18 15:37:47.807946	2025-05-18 16:14:47.807946	\N	completed	3
26576	15	270.00	5	2025-05-18 10:29:47.807946	2025-05-18 11:15:47.807946	\N	completed	3
26577	9	440.00	7	2025-05-18 21:21:47.807946	2025-05-18 22:08:47.807946	\N	completed	10
26578	16	280.00	5	2025-05-18 05:16:47.807946	2025-05-18 05:54:47.807946	\N	completed	1
26579	2	1000.00	6	2025-05-18 07:35:47.807946	2025-05-18 08:10:47.807946	\N	completed	6
26580	11	435.00	4	2025-05-18 19:24:47.807946	2025-05-18 20:00:47.807946	\N	completed	1
26581	15	420.00	5	2025-05-18 19:00:47.807946	2025-05-18 19:35:47.807946	\N	completed	9
26582	7	420.00	9	2025-05-18 21:24:47.807946	2025-05-18 22:07:47.807946	\N	completed	1
26583	12	420.00	7	2025-05-18 12:32:47.807946	2025-05-18 12:54:47.807946	\N	completed	3
26584	10	950.00	7	2025-05-18 08:59:47.807946	2025-05-18 09:19:47.807946	\N	completed	32
26585	11	525.00	4	2025-05-18 17:22:47.807946	2025-05-18 18:09:47.807946	\N	completed	10
26586	9	420.00	5	2025-05-18 22:52:47.807946	2025-05-18 23:32:47.807946	\N	completed	10
26587	12	750.00	4	2025-05-18 08:54:47.807946	2025-05-18 09:32:47.807946	\N	completed	34
26588	28	800.00	6	2025-05-18 16:05:47.807946	2025-05-18 16:31:47.807946	\N	completed	3
26589	12	650.00	9	2025-05-18 07:05:47.807946	2025-05-18 07:54:47.807946	\N	completed	3
26590	7	260.00	8	2025-05-18 05:59:47.807946	2025-05-18 06:22:47.807946	\N	completed	1
26591	8	495.00	8	2025-05-18 09:21:47.807946	2025-05-18 10:04:47.807946	\N	completed	3
26592	11	500.00	5	2025-05-18 20:10:47.807946	2025-05-18 20:44:47.807946	\N	completed	9
26593	10	340.00	6	2025-05-19 05:25:47.807946	2025-05-19 06:01:47.807946	\N	completed	3
26594	2	500.00	6	2025-05-19 20:02:47.807946	2025-05-19 20:26:47.807946	\N	completed	34
26595	10	560.00	9	2025-05-19 22:01:47.807946	2025-05-19 22:21:47.807946	\N	completed	32
26596	12	650.00	6	2025-05-19 08:22:47.807946	2025-05-19 09:00:47.807946	\N	completed	9
26597	11	480.00	5	2025-05-19 12:48:47.807946	2025-05-19 13:21:47.807946	\N	completed	6
26598	11	300.00	7	2025-05-19 15:38:47.807946	2025-05-19 16:04:47.807946	\N	completed	11
26599	7	345.00	9	2025-05-19 11:00:47.807946	2025-05-19 11:29:47.807946	\N	completed	1
26600	15	345.00	4	2025-05-19 15:27:47.807946	2025-05-19 15:58:47.807946	\N	completed	6
26601	2	360.00	5	2025-05-19 19:07:47.807946	2025-05-19 19:43:47.807946	\N	completed	9
26602	2	900.00	9	2025-05-19 08:09:47.807946	2025-05-19 08:38:47.807946	\N	completed	34
26603	28	440.00	6	2025-05-19 20:59:47.807946	2025-05-19 21:47:47.807946	\N	completed	6
26604	12	285.00	5	2025-05-19 11:33:47.807946	2025-05-19 11:56:47.807946	\N	completed	8
26605	28	500.00	4	2025-05-19 21:02:47.807946	2025-05-19 21:52:47.807946	\N	completed	11
26606	15	625.00	9	2025-05-19 16:27:47.807946	2025-05-19 16:55:47.807946	\N	completed	1
26607	2	390.00	4	2025-05-19 15:39:47.807946	2025-05-19 16:28:47.807946	\N	completed	9
26608	28	320.00	5	2025-05-19 05:51:47.807946	2025-05-19 06:35:47.807946	\N	completed	3
26609	28	420.00	6	2025-05-19 10:01:47.807946	2025-05-19 10:30:47.807946	\N	completed	11
26610	8	625.00	8	2025-05-19 18:21:47.807946	2025-05-19 18:53:47.807946	\N	completed	8
26611	11	375.00	7	2025-05-19 15:27:47.807946	2025-05-19 15:56:47.807946	\N	completed	3
26612	30	300.00	7	2025-05-19 20:24:47.807946	2025-05-19 20:55:47.807946	\N	completed	11
26613	8	400.00	7	2025-05-19 05:29:47.807946	2025-05-19 06:15:47.807946	\N	completed	10
26614	15	525.00	9	2025-05-19 08:52:47.807946	2025-05-19 09:36:47.807946	\N	completed	1
26615	7	550.00	8	2025-05-19 16:47:47.807946	2025-05-19 17:27:47.807946	\N	completed	34
26616	10	420.00	4	2025-05-19 20:08:47.807946	2025-05-19 20:38:47.807946	\N	completed	8
26617	8	700.00	9	2025-05-19 18:20:47.807946	2025-05-19 19:02:47.807946	\N	completed	9
26618	7	510.00	5	2025-05-19 15:50:47.807946	2025-05-19 16:16:47.807946	\N	completed	11
26619	28	525.00	4	2025-05-19 11:57:47.807946	2025-05-19 12:27:47.807946	\N	completed	9
26620	8	600.00	7	2025-05-19 07:01:47.807946	2025-05-19 07:26:47.807946	\N	completed	6
26621	28	360.00	8	2025-05-19 22:33:47.807946	2025-05-19 23:17:47.807946	\N	completed	3
26622	7	465.00	7	2025-05-19 10:39:47.807946	2025-05-19 11:02:47.807946	\N	completed	8
26623	28	375.00	8	2025-05-19 19:40:47.807946	2025-05-19 20:11:47.807946	\N	completed	6
26624	15	390.00	8	2025-05-20 10:28:47.807946	2025-05-20 11:03:47.807946	\N	completed	3
26625	2	525.00	5	2025-05-20 07:06:47.807946	2025-05-20 07:51:47.807946	\N	completed	11
26626	8	285.00	7	2025-05-20 09:20:47.807946	2025-05-20 09:42:47.807946	\N	completed	9
26627	9	725.00	6	2025-05-20 16:53:47.807946	2025-05-20 17:30:47.807946	\N	completed	8
26628	28	360.00	4	2025-05-20 22:39:47.807946	2025-05-20 23:04:47.807946	\N	completed	6
26629	7	360.00	6	2025-05-20 20:49:47.807946	2025-05-20 21:29:47.807946	\N	completed	36
26630	11	775.00	6	2025-05-20 16:07:47.807946	2025-05-20 16:33:47.807946	\N	completed	34
26631	15	600.00	5	2025-05-20 20:28:47.807946	2025-05-20 21:04:47.807946	\N	completed	11
26632	14	1025.00	6	2025-05-20 16:31:47.807946	2025-05-20 17:21:47.807946	\N	completed	9
26633	7	525.00	4	2025-05-20 07:10:47.807946	2025-05-20 07:38:47.807946	\N	completed	9
26634	28	600.00	8	2025-05-20 21:15:47.807946	2025-05-20 21:47:47.807946	\N	completed	11
26635	8	375.00	5	2025-05-20 09:48:47.807946	2025-05-20 10:31:47.807946	\N	completed	1
26636	12	800.00	7	2025-05-20 08:52:47.807946	2025-05-20 09:15:47.807946	\N	completed	8
26637	9	520.00	7	2025-05-20 21:42:47.807946	2025-05-20 22:12:47.807946	\N	completed	10
26638	9	255.00	6	2025-05-20 19:23:47.807946	2025-05-20 19:55:47.807946	\N	completed	11
26639	15	525.00	9	2025-05-20 13:26:47.807946	2025-05-20 14:02:47.807946	\N	completed	9
26640	9	1025.00	6	2025-05-20 17:02:47.807946	2025-05-20 17:33:47.807946	\N	completed	1
26641	10	440.00	4	2025-05-20 06:56:47.807946	2025-05-20 07:45:47.807946	\N	completed	10
26642	15	525.00	9	2025-05-21 12:07:47.807946	2025-05-21 12:33:47.807946	\N	completed	11
26643	15	315.00	4	2025-05-21 13:34:47.807946	2025-05-21 14:01:47.807946	\N	completed	6
26644	8	825.00	5	2025-05-21 18:58:47.807946	2025-05-21 19:38:47.807946	\N	completed	8
26645	16	300.00	4	2025-05-21 22:11:47.807946	2025-05-21 22:40:47.807946	\N	completed	8
26646	28	300.00	7	2025-05-21 05:50:47.807946	2025-05-21 06:40:47.807946	\N	completed	10
26647	16	435.00	4	2025-05-21 10:29:47.807946	2025-05-21 11:07:47.807946	\N	completed	9
26648	15	500.00	9	2025-05-21 20:23:47.807946	2025-05-21 21:13:47.807946	\N	completed	3
26649	30	825.00	4	2025-05-21 08:40:47.807946	2025-05-21 09:07:47.807946	\N	completed	32
26650	12	900.00	8	2025-05-21 17:49:47.807946	2025-05-21 18:16:47.807946	\N	completed	34
26651	2	480.00	7	2025-05-21 09:59:47.807946	2025-05-21 10:25:47.807946	\N	completed	6
26652	8	580.00	6	2025-05-21 20:23:47.807946	2025-05-21 21:00:47.807946	\N	completed	34
26653	30	340.00	4	2025-05-21 05:03:47.807946	2025-05-21 05:43:47.807946	\N	completed	9
26654	30	600.00	8	2025-05-21 21:03:47.807946	2025-05-21 21:24:47.807946	\N	completed	6
26655	9	950.00	9	2025-05-21 08:42:47.807946	2025-05-21 09:08:47.807946	\N	completed	10
26656	28	320.00	5	2025-05-21 06:54:47.807946	2025-05-21 07:14:47.807946	\N	completed	3
26657	28	495.00	8	2025-05-21 14:06:47.807946	2025-05-21 14:40:47.807946	\N	completed	8
26658	7	465.00	4	2025-05-21 10:45:47.807946	2025-05-21 11:16:47.807946	\N	completed	1
26659	15	950.00	5	2025-05-22 16:29:47.807946	2025-05-22 17:16:47.807946	\N	completed	10
26660	11	300.00	7	2025-05-22 06:33:47.807946	2025-05-22 06:56:47.807946	\N	completed	6
26661	8	575.00	7	2025-05-22 17:44:47.807946	2025-05-22 18:23:47.807946	\N	completed	36
26662	11	400.00	7	2025-05-22 22:29:47.807946	2025-05-22 23:03:47.807946	\N	completed	11
26663	12	800.00	6	2025-05-22 08:08:47.807946	2025-05-22 08:34:47.807946	\N	completed	34
26664	11	345.00	6	2025-05-22 10:45:47.807946	2025-05-22 11:16:47.807946	\N	completed	9
26665	11	390.00	6	2025-05-22 19:47:47.807946	2025-05-22 20:28:47.807946	\N	completed	6
26666	30	360.00	5	2025-05-22 21:01:47.807946	2025-05-22 21:30:47.807946	\N	completed	36
26667	11	925.00	7	2025-05-22 18:26:47.807946	2025-05-22 19:03:47.807946	\N	completed	36
26668	16	390.00	4	2025-05-22 10:33:47.807946	2025-05-22 10:58:47.807946	\N	completed	8
26669	16	285.00	4	2025-05-22 11:34:47.807946	2025-05-22 12:05:47.807946	\N	completed	34
26670	7	330.00	9	2025-05-22 09:16:47.807946	2025-05-22 09:46:47.807946	\N	completed	36
26671	10	700.00	9	2025-05-22 18:30:47.807946	2025-05-22 19:19:47.807946	\N	completed	1
26672	9	270.00	5	2025-05-22 12:26:47.807946	2025-05-22 12:52:47.807946	\N	completed	9
26673	8	390.00	9	2025-05-22 11:47:47.807946	2025-05-22 12:29:47.807946	\N	completed	3
26674	8	460.00	8	2025-05-22 05:09:47.807946	2025-05-22 05:53:47.807946	\N	completed	3
26675	15	260.00	7	2025-05-22 06:09:47.807946	2025-05-22 06:57:47.807946	\N	completed	6
26676	10	1000.00	8	2025-05-22 08:55:47.807946	2025-05-22 09:16:47.807946	\N	completed	11
26677	30	400.00	6	2025-05-22 05:37:47.807946	2025-05-22 06:24:47.807946	\N	completed	10
26678	2	495.00	4	2025-05-22 10:01:47.807946	2025-05-22 10:34:47.807946	\N	completed	3
26679	15	345.00	5	2025-05-23 10:10:47.807946	2025-05-23 10:58:47.807946	\N	completed	11
26680	28	575.00	7	2025-05-23 08:31:47.807946	2025-05-23 09:11:47.807946	\N	completed	34
26681	10	440.00	9	2025-05-23 21:17:47.807946	2025-05-23 21:58:47.807946	\N	completed	6
26682	15	525.00	8	2025-05-23 11:29:47.807946	2025-05-23 11:58:47.807946	\N	completed	10
26683	16	850.00	9	2025-05-23 16:12:47.807946	2025-05-23 16:45:47.807946	\N	completed	1
26684	14	360.00	4	2025-05-23 11:35:47.807946	2025-05-23 11:57:47.807946	\N	completed	10
26685	8	510.00	8	2025-05-23 11:24:47.807946	2025-05-23 11:48:47.807946	\N	completed	8
26686	7	550.00	8	2025-05-23 18:34:47.807946	2025-05-23 19:13:47.807946	\N	completed	8
26687	28	285.00	5	2025-05-23 12:17:47.807946	2025-05-23 13:05:47.807946	\N	completed	9
26688	11	625.00	5	2025-05-23 16:21:47.807946	2025-05-23 16:55:47.807946	\N	completed	34
26689	7	465.00	5	2025-05-23 10:15:47.807946	2025-05-23 10:43:47.807946	\N	completed	1
26690	14	465.00	7	2025-05-23 14:49:47.807946	2025-05-23 15:26:47.807946	\N	completed	34
26691	7	725.00	9	2025-05-23 18:03:47.807946	2025-05-23 18:45:47.807946	\N	completed	32
26692	28	300.00	9	2025-05-23 19:12:47.807946	2025-05-23 19:57:47.807946	\N	completed	8
26693	12	360.00	7	2025-05-23 14:38:47.807946	2025-05-23 14:59:47.807946	\N	completed	11
26694	10	315.00	4	2025-05-23 19:42:47.807946	2025-05-23 20:17:47.807946	\N	completed	1
26695	16	1000.00	7	2025-05-23 08:44:47.807946	2025-05-23 09:28:47.807946	\N	completed	34
26696	12	825.00	7	2025-05-24 16:32:47.807946	2025-05-24 17:01:47.807946	\N	completed	3
26697	2	300.00	8	2025-05-24 05:42:47.807946	2025-05-24 06:31:47.807946	\N	completed	34
26698	8	300.00	7	2025-05-24 20:43:47.807946	2025-05-24 21:33:47.807946	\N	completed	11
26699	9	375.00	6	2025-05-24 09:46:47.807946	2025-05-24 10:33:47.807946	\N	completed	32
26700	9	495.00	7	2025-05-24 12:53:47.807946	2025-05-24 13:16:47.807946	\N	completed	10
26701	7	600.00	4	2025-05-24 20:08:47.807946	2025-05-24 20:36:47.807946	\N	completed	6
26702	15	500.00	7	2025-05-24 05:02:47.807946	2025-05-24 05:52:47.807946	\N	completed	10
26703	9	525.00	8	2025-05-24 18:56:47.807946	2025-05-24 19:45:47.807946	\N	completed	32
26704	12	330.00	6	2025-05-24 14:21:47.807946	2025-05-24 15:09:47.807946	\N	completed	8
26705	9	525.00	7	2025-05-24 13:20:47.807946	2025-05-24 13:50:47.807946	\N	completed	9
26706	11	360.00	9	2025-05-24 10:20:47.807946	2025-05-24 10:41:47.807946	\N	completed	10
26707	10	925.00	6	2025-05-24 18:06:47.807946	2025-05-24 18:28:47.807946	\N	completed	1
26708	7	650.00	7	2025-05-24 17:06:47.807946	2025-05-24 17:55:47.807946	\N	completed	34
26709	30	525.00	4	2025-05-24 14:14:47.807946	2025-05-24 14:36:47.807946	\N	completed	11
26710	2	600.00	7	2025-05-24 21:59:47.807946	2025-05-24 22:45:47.807946	\N	completed	34
26711	2	525.00	8	2025-05-24 13:22:47.807946	2025-05-24 13:48:47.807946	\N	completed	10
26712	11	800.00	7	2025-05-24 17:40:47.807946	2025-05-24 18:03:47.807946	\N	completed	6
26713	28	525.00	7	2025-05-24 14:55:47.807946	2025-05-24 15:20:47.807946	\N	completed	36
26714	9	480.00	9	2025-05-24 20:38:47.807946	2025-05-24 21:06:47.807946	\N	completed	6
26715	12	465.00	4	2025-05-24 12:38:47.807946	2025-05-24 13:11:47.807946	\N	completed	11
26716	30	975.00	8	2025-05-24 18:55:47.807946	2025-05-24 19:29:47.807946	\N	completed	10
26717	30	775.00	7	2025-05-24 07:44:47.807946	2025-05-24 08:09:47.807946	\N	completed	36
26718	7	510.00	8	2025-05-25 15:18:47.807946	2025-05-25 15:50:47.807946	\N	completed	3
26719	12	580.00	8	2025-05-25 20:27:47.807946	2025-05-25 21:04:47.807946	\N	completed	9
26720	15	525.00	8	2025-05-25 10:17:47.807946	2025-05-25 11:06:47.807946	\N	completed	3
26721	28	900.00	8	2025-05-25 16:35:47.807946	2025-05-25 16:58:47.807946	\N	completed	36
26722	14	495.00	4	2025-05-25 14:27:47.807946	2025-05-25 14:50:47.807946	\N	completed	6
26723	11	315.00	9	2025-05-25 12:04:47.807946	2025-05-25 12:26:47.807946	\N	completed	1
26724	30	495.00	4	2025-05-25 12:34:47.807946	2025-05-25 13:12:47.807946	\N	completed	11
26725	7	400.00	9	2025-05-25 05:26:47.807946	2025-05-25 05:53:47.807946	\N	completed	32
26726	16	360.00	8	2025-05-25 05:40:47.807946	2025-05-25 06:29:47.807946	\N	completed	10
26727	30	340.00	6	2025-05-25 05:47:47.807946	2025-05-25 06:08:47.807946	\N	completed	36
26728	2	525.00	8	2025-05-25 09:56:47.807946	2025-05-25 10:16:47.807946	\N	completed	3
26729	14	270.00	6	2025-05-25 12:39:47.807946	2025-05-25 13:24:47.807946	\N	completed	6
26730	12	330.00	9	2025-05-25 12:22:47.807946	2025-05-25 13:08:47.807946	\N	completed	1
26731	9	380.00	6	2025-05-25 05:57:47.807946	2025-05-25 06:17:47.807946	\N	completed	9
26732	7	375.00	9	2025-05-25 10:08:47.807946	2025-05-25 10:51:47.807946	\N	completed	34
26733	12	360.00	7	2025-05-25 19:19:47.807946	2025-05-25 19:55:47.807946	\N	completed	10
26734	12	300.00	6	2025-05-25 10:07:47.807946	2025-05-25 10:53:47.807946	\N	completed	10
26735	14	465.00	5	2025-05-25 14:49:47.807946	2025-05-25 15:13:47.807946	\N	completed	6
26736	30	850.00	9	2025-05-25 07:35:47.807946	2025-05-25 08:09:47.807946	\N	completed	10
26737	14	420.00	6	2025-05-25 15:51:47.807946	2025-05-25 16:15:47.807946	\N	completed	10
26738	14	525.00	6	2025-05-25 18:55:47.807946	2025-05-25 19:39:47.807946	\N	completed	11
26739	8	465.00	5	2025-05-25 14:53:47.807946	2025-05-25 15:37:47.807946	\N	completed	36
26740	10	390.00	5	2025-05-25 12:22:47.807946	2025-05-25 12:43:47.807946	\N	completed	3
26741	30	560.00	9	2025-05-25 22:26:47.807946	2025-05-25 23:06:47.807946	\N	completed	34
26742	14	525.00	9	2025-05-25 13:01:47.807946	2025-05-25 13:46:47.807946	\N	completed	3
26743	2	330.00	4	2025-05-25 11:46:47.807946	2025-05-25 12:11:47.807946	\N	completed	1
26744	15	300.00	8	2025-05-25 06:34:47.807946	2025-05-25 07:05:47.807946	\N	completed	8
26745	10	260.00	5	2025-05-25 06:02:47.807946	2025-05-25 06:34:47.807946	\N	completed	32
26746	15	900.00	9	2025-05-25 16:25:47.807946	2025-05-25 16:49:47.807946	\N	completed	10
26747	28	285.00	5	2025-05-25 14:26:47.807946	2025-05-25 14:57:47.807946	\N	completed	32
26748	2	420.00	9	2025-05-25 05:43:47.807946	2025-05-25 06:07:47.807946	\N	completed	1
26749	28	925.00	4	2025-05-25 17:16:47.807946	2025-05-25 18:06:47.807946	\N	completed	9
26750	7	460.00	4	2025-05-26 05:05:47.807946	2025-05-26 05:31:47.807946	\N	completed	8
26751	10	495.00	6	2025-05-26 14:54:47.807946	2025-05-26 15:27:47.807946	\N	completed	11
26752	14	900.00	5	2025-05-26 18:14:47.807946	2025-05-26 18:38:47.807946	\N	completed	1
26753	30	285.00	9	2025-05-26 19:03:47.807946	2025-05-26 19:52:47.807946	\N	completed	9
26754	16	435.00	6	2025-05-26 14:49:47.807946	2025-05-26 15:15:47.807946	\N	completed	8
26755	8	320.00	4	2025-05-26 21:04:47.807946	2025-05-26 21:40:47.807946	\N	completed	1
26756	9	510.00	8	2025-05-26 14:21:47.807946	2025-05-26 14:41:47.807946	\N	completed	32
26757	10	850.00	5	2025-05-26 18:29:47.807946	2025-05-26 18:55:47.807946	\N	completed	9
26758	2	345.00	8	2025-05-26 19:35:47.807946	2025-05-26 20:13:47.807946	\N	completed	3
26759	28	360.00	4	2025-05-26 10:31:47.807946	2025-05-26 11:15:47.807946	\N	completed	1
26760	15	405.00	7	2025-05-26 09:40:47.807946	2025-05-26 10:13:47.807946	\N	completed	32
26761	9	315.00	9	2025-05-26 13:17:47.807946	2025-05-26 13:54:47.807946	\N	completed	34
26762	9	975.00	8	2025-05-26 18:32:47.807946	2025-05-26 19:09:47.807946	\N	completed	34
26763	16	850.00	7	2025-05-26 07:35:47.807946	2025-05-26 08:17:47.807946	\N	completed	8
26764	2	580.00	8	2025-05-26 20:15:47.807946	2025-05-26 20:47:47.807946	\N	completed	1
26765	16	725.00	4	2025-05-26 17:29:47.807946	2025-05-26 18:05:47.807946	\N	completed	36
26766	9	800.00	6	2025-05-26 16:48:47.807946	2025-05-26 17:22:47.807946	\N	completed	6
26767	9	240.00	6	2025-05-26 19:16:47.807946	2025-05-26 19:46:47.807946	\N	completed	32
26768	15	800.00	7	2025-05-26 17:03:47.807946	2025-05-26 17:33:47.807946	\N	completed	36
26769	30	560.00	6	2025-05-26 21:26:47.807946	2025-05-26 22:00:47.807946	\N	completed	3
26770	14	380.00	8	2025-05-26 20:13:47.807946	2025-05-26 20:33:47.807946	\N	completed	32
26771	16	675.00	4	2025-05-26 17:51:47.807946	2025-05-26 18:41:47.807946	\N	completed	1
26772	9	450.00	8	2025-05-26 19:21:47.807946	2025-05-26 20:11:47.807946	\N	completed	8
26773	8	320.00	8	2025-05-26 21:01:47.807946	2025-05-26 21:38:47.807946	\N	completed	10
26774	7	240.00	4	2025-05-27 19:01:47.807946	2025-05-27 19:48:47.807946	\N	completed	1
26775	12	320.00	4	2025-05-27 21:21:47.807946	2025-05-27 21:59:47.807946	\N	completed	34
26776	10	700.00	5	2025-05-27 08:50:47.807946	2025-05-27 09:32:47.807946	\N	completed	9
26777	8	600.00	4	2025-05-27 21:37:47.807946	2025-05-27 22:00:47.807946	\N	completed	6
26778	8	625.00	4	2025-05-27 16:07:47.807946	2025-05-27 16:34:47.807946	\N	completed	32
26779	2	875.00	9	2025-05-27 07:31:47.807946	2025-05-27 08:06:47.807946	\N	completed	34
26780	16	520.00	6	2025-05-27 21:55:47.807946	2025-05-27 22:24:47.807946	\N	completed	32
26781	2	775.00	6	2025-05-27 07:57:47.807946	2025-05-27 08:43:47.807946	\N	completed	3
26782	16	750.00	4	2025-05-27 08:39:47.807946	2025-05-27 09:11:47.807946	\N	completed	34
26783	16	390.00	9	2025-05-27 11:10:47.807946	2025-05-27 11:33:47.807946	\N	completed	11
26784	2	270.00	4	2025-05-27 14:06:47.807946	2025-05-27 14:53:47.807946	\N	completed	11
26785	9	580.00	9	2025-05-27 22:30:47.807946	2025-05-27 23:03:47.807946	\N	completed	34
26786	10	875.00	8	2025-05-27 17:16:47.807946	2025-05-27 18:03:47.807946	\N	completed	34
26787	8	525.00	8	2025-05-27 12:19:47.807946	2025-05-27 12:58:47.807946	\N	completed	6
26788	28	450.00	7	2025-05-27 19:58:47.807946	2025-05-27 20:48:47.807946	\N	completed	10
26789	16	280.00	8	2025-05-27 06:25:47.807946	2025-05-27 06:50:47.807946	\N	completed	11
26790	12	360.00	7	2025-05-27 05:58:47.807946	2025-05-27 06:22:47.807946	\N	completed	9
26791	28	525.00	4	2025-05-27 09:03:47.807946	2025-05-27 09:38:47.807946	\N	completed	3
26792	30	420.00	8	2025-05-27 13:32:47.807946	2025-05-27 13:59:47.807946	\N	completed	3
26793	7	440.00	9	2025-05-27 05:52:47.807946	2025-05-27 06:41:47.807946	\N	completed	9
26794	10	775.00	9	2025-05-28 17:31:47.807946	2025-05-28 17:53:47.807946	\N	completed	6
26795	30	510.00	8	2025-05-28 13:00:47.807946	2025-05-28 13:24:47.807946	\N	completed	36
26796	12	360.00	5	2025-05-28 06:36:47.807946	2025-05-28 07:25:47.807946	\N	completed	34
26797	16	440.00	5	2025-05-28 05:22:47.807946	2025-05-28 05:58:47.807946	\N	completed	9
26798	15	525.00	6	2025-05-28 13:52:47.807946	2025-05-28 14:35:47.807946	\N	completed	1
26799	8	345.00	5	2025-05-28 09:24:47.807946	2025-05-28 10:02:47.807946	\N	completed	10
26800	30	360.00	4	2025-05-28 10:49:47.807946	2025-05-28 11:19:47.807946	\N	completed	9
26801	2	435.00	5	2025-05-28 13:06:47.807946	2025-05-28 13:56:47.807946	\N	completed	9
26802	30	480.00	7	2025-05-28 06:19:47.807946	2025-05-28 06:50:47.807946	\N	completed	34
26803	7	975.00	4	2025-05-28 08:50:47.807946	2025-05-28 09:28:47.807946	\N	completed	36
26804	11	925.00	9	2025-05-28 17:29:47.807946	2025-05-28 18:11:47.807946	\N	completed	10
26805	8	495.00	6	2025-05-28 14:39:47.807946	2025-05-28 15:09:47.807946	\N	completed	32
26806	30	450.00	5	2025-05-28 12:53:47.807946	2025-05-28 13:35:47.807946	\N	completed	6
26807	9	465.00	9	2025-05-28 10:38:47.807946	2025-05-28 11:28:47.807946	\N	completed	8
26808	7	950.00	7	2025-05-28 17:23:47.807946	2025-05-28 18:07:47.807946	\N	completed	9
26809	14	825.00	9	2025-05-28 17:59:47.807946	2025-05-28 18:22:47.807946	\N	completed	6
26810	10	675.00	6	2025-05-28 08:31:47.807946	2025-05-28 09:15:47.807946	\N	completed	10
26811	14	520.00	8	2025-05-28 22:49:47.807946	2025-05-28 23:14:47.807946	\N	completed	1
26812	11	390.00	4	2025-05-29 10:36:47.807946	2025-05-29 11:05:47.807946	\N	completed	32
26813	14	480.00	6	2025-05-29 22:43:47.807946	2025-05-29 23:29:47.807946	\N	completed	34
26814	14	390.00	8	2025-05-29 10:43:47.807946	2025-05-29 11:13:47.807946	\N	completed	10
26815	15	600.00	8	2025-05-29 20:42:47.807946	2025-05-29 21:21:47.807946	\N	completed	34
26816	8	390.00	4	2025-05-29 11:20:47.807946	2025-05-29 11:48:47.807946	\N	completed	34
26817	8	460.00	7	2025-05-29 05:13:47.807946	2025-05-29 05:52:47.807946	\N	completed	8
26818	9	420.00	5	2025-05-29 05:01:47.807946	2025-05-29 05:29:47.807946	\N	completed	1
26819	10	525.00	6	2025-05-29 13:17:47.807946	2025-05-29 13:39:47.807946	\N	completed	11
26820	28	480.00	7	2025-05-29 06:35:47.807946	2025-05-29 07:05:47.807946	\N	completed	10
26821	14	300.00	5	2025-05-29 10:05:47.807946	2025-05-29 10:33:47.807946	\N	completed	36
26822	14	360.00	9	2025-05-29 15:06:47.807946	2025-05-29 15:42:47.807946	\N	completed	8
26823	2	315.00	7	2025-05-29 14:46:47.807946	2025-05-29 15:16:47.807946	\N	completed	10
26824	9	270.00	6	2025-05-29 10:26:47.807946	2025-05-29 11:08:47.807946	\N	completed	1
26825	2	345.00	7	2025-05-29 13:54:47.807946	2025-05-29 14:22:47.807946	\N	completed	3
26826	9	675.00	5	2025-05-29 18:44:47.807946	2025-05-29 19:14:47.807946	\N	completed	9
26827	14	435.00	5	2025-05-29 11:43:47.807946	2025-05-29 12:04:47.807946	\N	completed	11
26828	9	750.00	4	2025-05-29 07:28:47.807946	2025-05-29 08:03:47.807946	\N	completed	36
26829	11	525.00	4	2025-05-29 09:02:47.807946	2025-05-29 09:44:47.807946	\N	completed	3
26830	30	435.00	7	2025-05-29 19:10:47.807946	2025-05-29 20:00:47.807946	\N	completed	36
26831	10	625.00	5	2025-05-29 18:16:47.807946	2025-05-29 18:49:47.807946	\N	completed	10
26832	7	525.00	8	2025-05-29 16:01:47.807946	2025-05-29 16:29:47.807946	\N	completed	10
26833	28	450.00	9	2025-05-30 14:36:47.807946	2025-05-30 14:58:47.807946	\N	completed	36
26834	15	340.00	9	2025-05-30 22:29:47.807946	2025-05-30 23:14:47.807946	\N	completed	3
26835	14	480.00	5	2025-05-30 22:24:47.807946	2025-05-30 23:14:47.807946	\N	completed	1
26836	10	315.00	5	2025-05-30 11:45:47.807946	2025-05-30 12:19:47.807946	\N	completed	9
26837	15	575.00	7	2025-05-30 16:32:47.807946	2025-05-30 16:52:47.807946	\N	completed	36
26838	8	510.00	5	2025-05-30 15:31:47.807946	2025-05-30 15:55:47.807946	\N	completed	11
26839	2	520.00	4	2025-05-30 21:00:47.807946	2025-05-30 21:48:47.807946	\N	completed	32
26840	12	500.00	6	2025-05-30 21:03:47.807946	2025-05-30 21:31:47.807946	\N	completed	8
26841	10	360.00	9	2025-05-30 06:40:47.807946	2025-05-30 07:21:47.807946	\N	completed	9
26842	30	360.00	6	2025-05-30 14:43:47.807946	2025-05-30 15:32:47.807946	\N	completed	9
26843	15	500.00	4	2025-05-30 06:58:47.807946	2025-05-30 07:28:47.807946	\N	completed	34
26844	7	345.00	5	2025-05-30 12:54:47.807946	2025-05-30 13:38:47.807946	\N	completed	6
26845	30	285.00	6	2025-05-30 15:33:47.807946	2025-05-30 16:08:47.807946	\N	completed	8
26846	12	950.00	7	2025-05-30 08:22:47.807946	2025-05-30 08:45:47.807946	\N	completed	10
26847	16	480.00	5	2025-05-30 06:16:47.807946	2025-05-30 06:51:47.807946	\N	completed	3
26848	11	270.00	9	2025-05-30 13:24:47.807946	2025-05-30 14:11:47.807946	\N	completed	9
26849	12	510.00	4	2025-05-30 12:01:47.807946	2025-05-30 12:23:47.807946	\N	completed	11
26850	16	1000.00	5	2025-05-30 18:35:47.807946	2025-05-30 19:16:47.807946	\N	completed	32
26851	16	450.00	4	2025-05-30 11:06:47.807946	2025-05-30 11:34:47.807946	\N	completed	34
26852	7	315.00	6	2025-05-30 15:44:47.807946	2025-05-30 16:23:47.807946	\N	completed	36
26853	30	625.00	4	2025-05-30 08:51:47.807946	2025-05-30 09:19:47.807946	\N	completed	36
26854	28	480.00	5	2025-05-30 14:22:47.807946	2025-05-30 14:49:47.807946	\N	completed	36
26855	11	800.00	5	2025-05-30 16:00:47.807946	2025-05-30 16:22:47.807946	\N	completed	10
26856	30	420.00	4	2025-05-30 09:45:47.807946	2025-05-30 10:28:47.807946	\N	completed	10
26857	9	550.00	6	2025-05-30 07:17:47.807946	2025-05-30 07:57:47.807946	\N	completed	10
26858	8	340.00	5	2025-05-30 05:19:47.807946	2025-05-30 05:49:47.807946	\N	completed	32
26859	10	320.00	5	2025-05-30 05:13:47.807946	2025-05-30 05:49:47.807946	\N	completed	1
26860	12	390.00	9	2025-05-30 13:56:47.807946	2025-05-30 14:21:47.807946	\N	completed	36
26861	7	540.00	6	2025-05-31 22:50:47.807946	2025-05-31 23:20:47.807946	\N	completed	8
26862	15	280.00	7	2025-05-31 06:48:47.807946	2025-05-31 07:36:47.807946	\N	completed	1
26863	30	420.00	5	2025-05-31 12:43:47.807946	2025-05-31 13:12:47.807946	\N	completed	32
26864	11	400.00	7	2025-05-31 06:37:47.807946	2025-05-31 07:20:47.807946	\N	completed	34
26865	12	450.00	4	2025-05-31 13:41:47.807946	2025-05-31 14:13:47.807946	\N	completed	10
26866	30	450.00	5	2025-05-31 19:08:47.807946	2025-05-31 19:38:47.807946	\N	completed	32
26867	12	360.00	8	2025-05-31 05:32:47.807946	2025-05-31 06:03:47.807946	\N	completed	10
26868	14	390.00	4	2025-05-31 14:26:47.807946	2025-05-31 14:53:47.807946	\N	completed	6
26869	30	675.00	5	2025-05-31 08:56:47.807946	2025-05-31 09:44:47.807946	\N	completed	11
26870	8	850.00	9	2025-05-31 07:45:47.807946	2025-05-31 08:07:47.807946	\N	completed	36
26871	7	260.00	7	2025-05-31 06:10:47.807946	2025-05-31 06:36:47.807946	\N	completed	3
26872	8	400.00	5	2025-05-31 06:50:47.807946	2025-05-31 07:40:47.807946	\N	completed	32
26873	11	450.00	9	2025-05-31 09:22:47.807946	2025-05-31 09:58:47.807946	\N	completed	34
26874	30	495.00	8	2025-05-31 12:56:47.807946	2025-05-31 13:44:47.807946	\N	completed	8
26875	14	435.00	9	2025-05-31 15:36:47.807946	2025-05-31 16:25:47.807946	\N	completed	34
26876	16	525.00	8	2025-05-31 11:59:47.807946	2025-05-31 12:30:47.807946	\N	completed	1
26877	2	1025.00	7	2025-05-31 08:18:47.807946	2025-05-31 08:40:47.807946	\N	completed	36
26878	30	300.00	6	2025-05-31 11:59:47.807946	2025-05-31 12:38:47.807946	\N	completed	10
26879	12	525.00	7	2025-05-31 16:02:47.807946	2025-05-31 16:36:47.807946	\N	completed	9
26880	2	510.00	6	2025-05-31 10:17:47.807946	2025-05-31 10:38:47.807946	\N	completed	32
26881	30	330.00	9	2025-05-31 11:27:47.807946	2025-05-31 12:10:47.807946	\N	completed	3
26882	9	435.00	4	2025-05-31 12:10:47.807946	2025-05-31 13:00:47.807946	\N	completed	34
26883	30	550.00	8	2025-05-31 16:32:47.807946	2025-05-31 17:07:47.807946	\N	completed	9
26884	12	550.00	5	2025-05-31 08:49:47.807946	2025-05-31 09:14:47.807946	\N	completed	3
26885	8	380.00	4	2025-06-01 20:46:47.807946	2025-06-01 21:26:47.807946	\N	completed	34
26886	8	460.00	8	2025-06-01 20:32:47.807946	2025-06-01 21:16:47.807946	\N	completed	10
26887	15	300.00	9	2025-06-01 11:19:47.807946	2025-06-01 12:03:47.807946	\N	completed	1
26888	9	600.00	9	2025-06-01 18:52:47.807946	2025-06-01 19:36:47.807946	\N	completed	8
26889	14	300.00	8	2025-06-01 20:39:47.807946	2025-06-01 21:22:47.807946	\N	completed	8
26890	15	450.00	4	2025-06-01 19:29:47.807946	2025-06-01 20:06:47.807946	\N	completed	3
26891	7	345.00	7	2025-06-01 15:48:47.807946	2025-06-01 16:38:47.807946	\N	completed	6
26892	30	495.00	5	2025-06-01 11:09:47.807946	2025-06-01 11:42:47.807946	\N	completed	6
26893	11	850.00	7	2025-06-01 18:42:47.807946	2025-06-01 19:16:47.807946	\N	completed	9
26894	30	600.00	6	2025-06-01 21:13:47.807946	2025-06-01 21:59:47.807946	\N	completed	6
26895	9	420.00	8	2025-06-01 14:23:47.807946	2025-06-01 15:10:47.807946	\N	completed	36
26896	15	315.00	7	2025-06-01 13:56:47.807946	2025-06-01 14:34:47.807946	\N	completed	9
26897	8	525.00	6	2025-06-01 10:14:47.807946	2025-06-01 10:53:47.807946	\N	completed	32
26898	10	300.00	7	2025-06-01 10:38:47.807946	2025-06-01 11:11:47.807946	\N	completed	36
26899	10	550.00	6	2025-06-01 07:45:47.807946	2025-06-01 08:06:47.807946	\N	completed	1
26900	2	480.00	9	2025-06-01 11:22:47.807946	2025-06-01 12:12:47.807946	\N	completed	11
26901	10	315.00	6	2025-06-01 15:00:47.807946	2025-06-01 15:31:47.807946	\N	completed	3
26902	7	1000.00	4	2025-06-01 17:05:47.807946	2025-06-01 17:30:47.807946	\N	completed	6
26903	15	360.00	9	2025-06-01 09:35:47.807946	2025-06-01 10:17:47.807946	\N	completed	34
26904	2	580.00	6	2025-06-01 20:47:47.807946	2025-06-01 21:25:47.807946	\N	completed	10
26905	14	435.00	9	2025-06-01 13:40:47.807946	2025-06-01 14:24:47.807946	\N	completed	34
26906	8	775.00	5	2025-06-01 16:39:47.807946	2025-06-01 17:22:47.807946	\N	completed	10
26907	12	480.00	9	2025-06-01 09:04:47.807946	2025-06-01 09:47:47.807946	\N	completed	9
26908	30	285.00	6	2025-06-01 19:37:47.807946	2025-06-01 20:18:47.807946	\N	completed	6
26909	10	400.00	9	2025-06-02 21:57:47.807946	2025-06-02 22:28:47.807946	\N	completed	36
26910	30	440.00	7	2025-06-02 20:35:47.807946	2025-06-02 21:19:47.807946	\N	completed	9
26911	11	600.00	9	2025-06-02 20:18:47.807946	2025-06-02 20:41:47.807946	\N	completed	32
26912	30	360.00	6	2025-06-02 06:43:47.807946	2025-06-02 07:05:47.807946	\N	completed	10
26913	14	510.00	8	2025-06-02 14:25:47.807946	2025-06-02 15:13:47.807946	\N	completed	10
26914	10	240.00	5	2025-06-02 19:24:47.807946	2025-06-02 19:56:47.807946	\N	completed	32
26915	28	1025.00	9	2025-06-02 07:20:47.807946	2025-06-02 07:45:47.807946	\N	completed	3
26916	12	575.00	4	2025-06-02 08:56:47.807946	2025-06-02 09:36:47.807946	\N	completed	34
26917	14	510.00	7	2025-06-02 15:48:47.807946	2025-06-02 16:19:47.807946	\N	completed	6
26918	10	465.00	4	2025-06-02 15:58:47.807946	2025-06-02 16:44:47.807946	\N	completed	36
26919	15	420.00	9	2025-06-02 06:25:47.807946	2025-06-02 06:48:47.807946	\N	completed	36
26920	30	380.00	4	2025-06-02 22:34:47.807946	2025-06-02 22:55:47.807946	\N	completed	11
26921	7	500.00	8	2025-06-02 21:53:47.807946	2025-06-02 22:43:47.807946	\N	completed	32
26922	7	330.00	7	2025-06-02 09:40:47.807946	2025-06-02 10:00:47.807946	\N	completed	10
26923	28	420.00	8	2025-06-02 15:00:47.807946	2025-06-02 15:44:47.807946	\N	completed	32
26924	2	725.00	6	2025-06-02 17:13:47.807946	2025-06-02 17:58:47.807946	\N	completed	10
26925	9	440.00	9	2025-06-02 06:26:47.807946	2025-06-02 06:49:47.807946	\N	completed	9
26926	7	380.00	8	2025-06-02 20:28:47.807946	2025-06-02 21:11:47.807946	\N	completed	1
26927	9	825.00	4	2025-06-02 16:59:47.807946	2025-06-02 17:29:47.807946	\N	completed	34
26928	16	260.00	5	2025-06-02 05:39:47.807946	2025-06-02 06:19:47.807946	\N	completed	11
26929	14	285.00	7	2025-06-02 11:45:47.807946	2025-06-02 12:33:47.807946	\N	completed	8
26930	14	270.00	7	2025-06-02 09:01:47.807946	2025-06-02 09:46:47.807946	\N	completed	36
26931	8	900.00	6	2025-06-02 18:18:47.807946	2025-06-02 18:49:47.807946	\N	completed	3
26932	15	435.00	5	2025-06-03 09:52:47.807946	2025-06-03 10:38:47.807946	\N	completed	11
26933	12	440.00	8	2025-06-03 22:29:47.807946	2025-06-03 23:03:47.807946	\N	completed	11
26934	28	750.00	8	2025-06-03 17:28:47.807946	2025-06-03 18:17:47.807946	\N	completed	3
26935	12	260.00	4	2025-06-03 06:57:47.807946	2025-06-03 07:19:47.807946	\N	completed	3
26936	28	525.00	7	2025-06-03 13:08:47.807946	2025-06-03 13:40:47.807946	\N	completed	10
26937	28	600.00	5	2025-06-03 08:45:47.807946	2025-06-03 09:33:47.807946	\N	completed	8
26938	28	525.00	9	2025-06-03 07:55:47.807946	2025-06-03 08:16:47.807946	\N	completed	36
26939	14	380.00	6	2025-06-03 22:09:47.807946	2025-06-03 22:29:47.807946	\N	completed	34
26940	11	375.00	7	2025-06-03 15:20:47.807946	2025-06-03 16:10:47.807946	\N	completed	3
26941	30	300.00	6	2025-06-03 22:07:47.807946	2025-06-03 22:32:47.807946	\N	completed	8
26942	15	520.00	8	2025-06-03 20:41:47.807946	2025-06-03 21:17:47.807946	\N	completed	8
26943	15	600.00	4	2025-06-03 21:50:47.807946	2025-06-03 22:20:47.807946	\N	completed	36
26944	28	300.00	6	2025-06-03 06:22:47.807946	2025-06-03 07:07:47.807946	\N	completed	3
26945	8	875.00	4	2025-06-03 07:02:47.807946	2025-06-03 07:43:47.807946	\N	completed	11
26946	10	440.00	8	2025-06-03 22:20:47.807946	2025-06-03 22:47:47.807946	\N	completed	6
26947	8	465.00	8	2025-06-03 09:22:47.807946	2025-06-03 09:54:47.807946	\N	completed	6
26948	15	875.00	7	2025-06-03 16:11:47.807946	2025-06-03 16:46:47.807946	\N	completed	3
26949	30	345.00	8	2025-06-03 11:10:47.807946	2025-06-03 11:58:47.807946	\N	completed	36
26950	2	375.00	9	2025-06-03 12:09:47.807946	2025-06-03 12:53:47.807946	\N	completed	3
26951	10	405.00	8	2025-06-03 10:53:47.807946	2025-06-03 11:25:47.807946	\N	completed	11
26952	28	320.00	9	2025-06-04 20:54:47.807946	2025-06-04 21:35:47.807946	\N	completed	8
26953	15	380.00	8	2025-06-04 22:31:47.807946	2025-06-04 23:06:47.807946	\N	completed	10
26954	15	435.00	4	2025-06-04 19:14:47.807946	2025-06-04 20:04:47.807946	\N	completed	3
26955	30	405.00	8	2025-06-04 12:25:47.807946	2025-06-04 12:59:47.807946	\N	completed	6
26956	7	520.00	5	2025-06-04 20:55:47.807946	2025-06-04 21:26:47.807946	\N	completed	34
26957	9	725.00	5	2025-06-04 07:23:47.807946	2025-06-04 07:43:47.807946	\N	completed	10
26958	16	1000.00	8	2025-06-04 17:46:47.807946	2025-06-04 18:21:47.807946	\N	completed	32
26959	12	800.00	5	2025-06-04 16:43:47.807946	2025-06-04 17:22:47.807946	\N	completed	3
26960	30	850.00	4	2025-06-04 17:44:47.807946	2025-06-04 18:10:47.807946	\N	completed	6
26961	15	435.00	8	2025-06-04 15:25:47.807946	2025-06-04 15:54:47.807946	\N	completed	34
26962	30	450.00	5	2025-06-04 12:46:47.807946	2025-06-04 13:27:47.807946	\N	completed	6
26963	7	375.00	6	2025-06-04 12:21:47.807946	2025-06-04 12:48:47.807946	\N	completed	3
26964	16	465.00	6	2025-06-04 14:26:47.807946	2025-06-04 15:03:47.807946	\N	completed	1
26965	10	900.00	6	2025-06-04 16:49:47.807946	2025-06-04 17:34:47.807946	\N	completed	10
26966	14	400.00	6	2025-06-04 05:06:47.807946	2025-06-04 05:46:47.807946	\N	completed	32
26967	16	875.00	5	2025-06-04 17:30:47.807946	2025-06-04 17:52:47.807946	\N	completed	1
26968	12	360.00	4	2025-06-05 13:04:47.807946	2025-06-05 13:52:47.807946	\N	completed	34
26969	16	975.00	5	2025-06-05 17:01:47.807946	2025-06-05 17:23:47.807946	\N	completed	1
26970	14	450.00	9	2025-06-05 10:06:47.807946	2025-06-05 10:42:47.807946	\N	completed	32
26971	2	300.00	9	2025-06-05 12:54:47.807946	2025-06-05 13:15:47.807946	\N	completed	10
26972	10	525.00	4	2025-06-05 12:09:47.807946	2025-06-05 12:47:47.807946	\N	completed	10
26973	14	525.00	8	2025-06-05 10:22:47.807946	2025-06-05 11:02:47.807946	\N	completed	9
26974	7	875.00	9	2025-06-05 18:29:47.807946	2025-06-05 19:19:47.807946	\N	completed	11
26975	28	345.00	7	2025-06-05 11:39:47.807946	2025-06-05 12:10:47.807946	\N	completed	6
26976	16	540.00	5	2025-06-05 21:44:47.807946	2025-06-05 22:17:47.807946	\N	completed	1
26977	2	270.00	4	2025-06-05 10:11:47.807946	2025-06-05 10:51:47.807946	\N	completed	11
26978	30	345.00	9	2025-06-05 10:19:47.807946	2025-06-05 10:48:47.807946	\N	completed	34
26979	10	315.00	7	2025-06-05 13:57:47.807946	2025-06-05 14:43:47.807946	\N	completed	32
26980	28	750.00	9	2025-06-05 07:08:47.807946	2025-06-05 07:52:47.807946	\N	completed	1
26981	28	525.00	7	2025-06-05 17:41:47.807946	2025-06-05 18:26:47.807946	\N	completed	11
26982	9	315.00	5	2025-06-05 15:35:47.807946	2025-06-05 16:04:47.807946	\N	completed	36
26983	12	400.00	5	2025-06-05 05:07:47.807946	2025-06-05 05:38:47.807946	\N	completed	6
26984	14	420.00	9	2025-06-05 09:34:47.807946	2025-06-05 09:56:47.807946	\N	completed	11
26985	14	320.00	6	2025-06-05 20:55:47.807946	2025-06-05 21:18:47.807946	\N	completed	32
26986	8	440.00	7	2025-06-05 05:12:47.807946	2025-06-05 05:42:47.807946	\N	completed	32
26987	16	495.00	7	2025-06-05 11:13:47.807946	2025-06-05 11:50:47.807946	\N	completed	10
26988	16	300.00	9	2025-06-05 22:15:47.807946	2025-06-05 22:52:47.807946	\N	completed	6
26989	28	825.00	4	2025-06-05 16:17:47.807946	2025-06-05 16:55:47.807946	\N	completed	10
26990	14	405.00	4	2025-06-06 10:34:47.807946	2025-06-06 11:16:47.807946	\N	completed	32
26991	12	320.00	7	2025-06-06 21:34:47.807946	2025-06-06 22:24:47.807946	\N	completed	3
26992	11	495.00	5	2025-06-06 13:37:47.807946	2025-06-06 14:23:47.807946	\N	completed	1
26993	14	375.00	9	2025-06-06 13:40:47.807946	2025-06-06 14:09:47.807946	\N	completed	32
26994	11	255.00	9	2025-06-06 19:11:47.807946	2025-06-06 19:55:47.807946	\N	completed	10
26995	10	270.00	7	2025-06-06 12:21:47.807946	2025-06-06 13:11:47.807946	\N	completed	8
26996	11	480.00	4	2025-06-06 13:52:47.807946	2025-06-06 14:26:47.807946	\N	completed	1
26997	16	270.00	8	2025-06-06 14:58:47.807946	2025-06-06 15:30:47.807946	\N	completed	6
26998	8	580.00	8	2025-06-06 21:15:47.807946	2025-06-06 21:53:47.807946	\N	completed	34
26999	9	260.00	7	2025-06-06 06:15:47.807946	2025-06-06 06:37:47.807946	\N	completed	11
27000	10	525.00	7	2025-06-06 11:33:47.807946	2025-06-06 12:19:47.807946	\N	completed	34
27001	30	625.00	9	2025-06-06 16:39:47.807946	2025-06-06 17:15:47.807946	\N	completed	1
27002	7	1000.00	6	2025-06-06 17:31:47.807946	2025-06-06 18:07:47.807946	\N	completed	10
27003	9	465.00	5	2025-06-06 10:17:47.807946	2025-06-06 10:45:47.807946	\N	completed	10
27004	15	330.00	4	2025-06-06 19:44:47.807946	2025-06-06 20:27:47.807946	\N	completed	10
27005	30	525.00	8	2025-06-06 09:18:47.807946	2025-06-06 10:04:47.807946	\N	completed	10
27006	16	750.00	9	2025-06-06 08:59:47.807946	2025-06-06 09:19:47.807946	\N	completed	9
27007	8	510.00	6	2025-06-06 10:38:47.807946	2025-06-06 11:13:47.807946	\N	completed	3
27008	9	400.00	7	2025-06-06 06:16:47.807946	2025-06-06 06:55:47.807946	\N	completed	8
27009	7	825.00	9	2025-06-06 16:04:47.807946	2025-06-06 16:25:47.807946	\N	completed	9
27010	15	460.00	7	2025-06-06 22:53:47.807946	2025-06-06 23:41:47.807946	\N	completed	11
27011	16	390.00	9	2025-06-06 09:24:47.807946	2025-06-06 09:53:47.807946	\N	completed	9
27012	8	400.00	8	2025-06-06 06:46:47.807946	2025-06-06 07:34:47.807946	\N	completed	1
27013	10	480.00	8	2025-06-06 20:09:47.807946	2025-06-06 20:30:47.807946	\N	completed	6
27014	15	525.00	9	2025-06-06 14:46:47.807946	2025-06-06 15:34:47.807946	\N	completed	10
27015	15	825.00	9	2025-06-06 08:21:47.807946	2025-06-06 08:45:47.807946	\N	completed	6
27016	9	260.00	8	2025-06-06 05:54:47.807946	2025-06-06 06:27:47.807946	\N	completed	36
27017	30	405.00	4	2025-06-06 09:34:47.807946	2025-06-06 10:03:47.807946	\N	completed	9
27018	16	510.00	7	2025-06-06 10:32:47.807946	2025-06-06 11:14:47.807946	\N	completed	9
27019	8	300.00	9	2025-06-07 20:36:47.807946	2025-06-07 21:14:47.807946	\N	completed	6
27020	28	495.00	6	2025-06-07 15:04:47.807946	2025-06-07 15:30:47.807946	\N	completed	34
27021	10	460.00	6	2025-06-07 22:24:47.807946	2025-06-07 22:58:47.807946	\N	completed	36
27022	8	725.00	5	2025-06-07 08:52:47.807946	2025-06-07 09:32:47.807946	\N	completed	3
27023	10	345.00	5	2025-06-07 19:58:47.807946	2025-06-07 20:21:47.807946	\N	completed	3
27024	12	725.00	6	2025-06-07 08:18:47.807946	2025-06-07 08:40:47.807946	\N	completed	34
27025	9	925.00	6	2025-06-07 07:31:47.807946	2025-06-07 08:10:47.807946	\N	completed	32
27026	12	800.00	7	2025-06-07 08:25:47.807946	2025-06-07 09:00:47.807946	\N	completed	3
27027	10	440.00	8	2025-06-07 22:10:47.807946	2025-06-07 22:56:47.807946	\N	completed	1
27028	2	285.00	9	2025-06-07 11:15:47.807946	2025-06-07 11:51:47.807946	\N	completed	1
27029	15	300.00	7	2025-06-07 15:31:47.807946	2025-06-07 15:58:47.807946	\N	completed	32
27030	28	465.00	9	2025-06-07 13:43:47.807946	2025-06-07 14:11:47.807946	\N	completed	32
27031	14	360.00	9	2025-06-07 20:15:47.807946	2025-06-07 20:52:47.807946	\N	completed	11
27032	30	270.00	8	2025-06-07 19:48:47.807946	2025-06-07 20:15:47.807946	\N	completed	34
27033	9	320.00	5	2025-06-07 06:18:47.807946	2025-06-07 07:01:47.807946	\N	completed	11
27034	8	300.00	9	2025-06-07 14:22:47.807946	2025-06-07 14:45:47.807946	\N	completed	11
27035	28	420.00	4	2025-06-07 21:10:47.807946	2025-06-07 21:44:47.807946	\N	completed	10
27036	9	600.00	8	2025-06-07 18:42:47.807946	2025-06-07 19:26:47.807946	\N	completed	1
27037	7	875.00	9	2025-06-07 18:51:47.807946	2025-06-07 19:19:47.807946	\N	completed	6
27038	28	315.00	8	2025-06-07 10:50:47.807946	2025-06-07 11:11:47.807946	\N	completed	6
27039	30	330.00	6	2025-06-07 15:52:47.807946	2025-06-07 16:41:47.807946	\N	completed	8
27040	30	465.00	9	2025-06-07 13:34:47.807946	2025-06-07 14:02:47.807946	\N	completed	3
27041	2	575.00	9	2025-06-07 08:29:47.807946	2025-06-07 08:59:47.807946	\N	completed	3
27042	11	850.00	9	2025-06-07 16:07:47.807946	2025-06-07 16:30:47.807946	\N	completed	9
27043	14	495.00	5	2025-06-07 10:26:47.807946	2025-06-07 10:47:47.807946	\N	completed	36
27044	28	315.00	5	2025-06-07 12:26:47.807946	2025-06-07 12:59:47.807946	\N	completed	34
27045	2	510.00	5	2025-06-07 11:54:47.807946	2025-06-07 12:33:47.807946	\N	completed	8
27046	10	480.00	6	2025-06-07 14:42:47.807946	2025-06-07 15:09:47.807946	\N	completed	6
27047	14	360.00	7	2025-06-07 22:17:47.807946	2025-06-07 23:05:47.807946	\N	completed	11
27048	30	315.00	8	2025-06-07 12:33:47.807946	2025-06-07 13:14:47.807946	\N	completed	10
27049	9	405.00	9	2025-06-08 15:41:47.807946	2025-06-08 16:08:47.807946	\N	completed	1
27050	10	390.00	7	2025-06-08 14:52:47.807946	2025-06-08 15:20:47.807946	\N	completed	6
27051	11	925.00	9	2025-06-08 16:43:47.807946	2025-06-08 17:08:47.807946	\N	completed	36
27052	30	675.00	6	2025-06-08 08:58:47.807946	2025-06-08 09:31:47.807946	\N	completed	8
27053	8	1000.00	7	2025-06-08 17:36:47.807946	2025-06-08 18:11:47.807946	\N	completed	8
27054	12	450.00	5	2025-06-08 09:44:47.807946	2025-06-08 10:23:47.807946	\N	completed	9
27055	9	390.00	5	2025-06-08 13:18:47.807946	2025-06-08 13:57:47.807946	\N	completed	34
27056	2	510.00	5	2025-06-08 12:23:47.807946	2025-06-08 13:08:47.807946	\N	completed	34
27057	28	405.00	8	2025-06-08 19:17:47.807946	2025-06-08 19:52:47.807946	\N	completed	36
27058	15	345.00	7	2025-06-08 19:02:47.807946	2025-06-08 19:26:47.807946	\N	completed	34
27059	15	270.00	4	2025-06-08 11:54:47.807946	2025-06-08 12:36:47.807946	\N	completed	11
27060	2	525.00	7	2025-06-08 10:07:47.807946	2025-06-08 10:35:47.807946	\N	completed	3
27061	11	495.00	9	2025-06-08 10:34:47.807946	2025-06-08 11:08:47.807946	\N	completed	3
27062	2	550.00	9	2025-06-08 16:48:47.807946	2025-06-08 17:08:47.807946	\N	completed	1
27063	8	270.00	7	2025-06-08 10:23:47.807946	2025-06-08 10:49:47.807946	\N	completed	32
27064	14	450.00	6	2025-06-08 19:40:47.807946	2025-06-08 20:25:47.807946	\N	completed	8
27065	28	340.00	5	2025-06-08 20:03:47.807946	2025-06-08 20:24:47.807946	\N	completed	32
27066	12	550.00	6	2025-06-08 18:18:47.807946	2025-06-08 19:07:47.807946	\N	completed	8
27067	9	550.00	8	2025-06-08 07:15:47.807946	2025-06-08 07:39:47.807946	\N	completed	11
27068	16	375.00	5	2025-06-08 11:48:47.807946	2025-06-08 12:18:47.807946	\N	completed	11
27069	9	600.00	7	2025-06-08 07:04:47.807946	2025-06-08 07:54:47.807946	\N	completed	11
27070	7	700.00	7	2025-06-08 17:13:47.807946	2025-06-08 18:01:47.807946	\N	completed	6
27071	15	330.00	9	2025-06-09 13:24:47.807946	2025-06-09 13:51:47.807946	\N	completed	11
27072	16	900.00	9	2025-06-09 17:13:47.807946	2025-06-09 17:40:47.807946	\N	completed	36
27073	30	525.00	4	2025-06-09 12:48:47.807946	2025-06-09 13:26:47.807946	\N	completed	3
27074	9	320.00	6	2025-06-09 22:33:47.807946	2025-06-09 22:59:47.807946	\N	completed	3
27075	7	525.00	6	2025-06-09 17:43:47.807946	2025-06-09 18:16:47.807946	\N	completed	32
27076	8	825.00	9	2025-06-09 08:32:47.807946	2025-06-09 09:07:47.807946	\N	completed	9
27077	12	420.00	5	2025-06-09 10:11:47.807946	2025-06-09 10:47:47.807946	\N	completed	32
27078	7	510.00	5	2025-06-09 14:06:47.807946	2025-06-09 14:27:47.807946	\N	completed	1
27079	7	450.00	9	2025-06-09 11:23:47.807946	2025-06-09 12:04:47.807946	\N	completed	10
27080	12	315.00	6	2025-06-09 14:35:47.807946	2025-06-09 15:02:47.807946	\N	completed	6
27081	15	300.00	6	2025-06-09 22:48:47.807946	2025-06-09 23:33:47.807946	\N	completed	32
27082	9	460.00	8	2025-06-09 06:45:47.807946	2025-06-09 07:25:47.807946	\N	completed	1
27083	12	300.00	7	2025-06-09 11:59:47.807946	2025-06-09 12:19:47.807946	\N	completed	34
27084	14	510.00	6	2025-06-09 14:54:47.807946	2025-06-09 15:20:47.807946	\N	completed	6
27085	28	925.00	8	2025-06-09 18:40:47.807946	2025-06-09 19:30:47.807946	\N	completed	32
27086	9	750.00	9	2025-06-09 18:33:47.807946	2025-06-09 19:01:47.807946	\N	completed	8
27087	30	435.00	9	2025-06-09 12:29:47.807946	2025-06-09 12:50:47.807946	\N	completed	9
27088	16	320.00	8	2025-06-09 22:56:47.807946	2025-06-09 23:20:47.807946	\N	completed	8
27089	2	300.00	5	2025-06-09 05:04:47.807946	2025-06-09 05:26:47.807946	\N	completed	11
27090	12	495.00	8	2025-06-09 14:53:47.807946	2025-06-09 15:42:47.807946	\N	completed	34
27091	16	500.00	7	2025-06-09 06:09:47.807946	2025-06-09 06:48:47.807946	\N	completed	9
27092	12	725.00	9	2025-06-09 16:47:47.807946	2025-06-09 17:13:47.807946	\N	completed	11
27093	9	495.00	9	2025-06-09 11:59:47.807946	2025-06-09 12:24:47.807946	\N	completed	32
27094	15	320.00	4	2025-06-09 06:33:47.807946	2025-06-09 06:56:47.807946	\N	completed	11
27095	12	340.00	8	2025-06-09 05:21:47.807946	2025-06-09 05:56:47.807946	\N	completed	3
27096	2	375.00	4	2025-06-10 13:51:47.807946	2025-06-10 14:19:47.807946	\N	completed	8
27097	14	525.00	8	2025-06-10 10:03:47.807946	2025-06-10 10:24:47.807946	\N	completed	32
27098	2	525.00	4	2025-06-10 13:02:47.807946	2025-06-10 13:26:47.807946	\N	completed	6
27099	28	875.00	7	2025-06-10 08:18:47.807946	2025-06-10 08:41:47.807946	\N	completed	1
27100	28	270.00	8	2025-06-10 19:39:47.807946	2025-06-10 20:05:47.807946	\N	completed	36
27101	2	480.00	6	2025-06-10 10:09:47.807946	2025-06-10 10:44:47.807946	\N	completed	36
27102	7	480.00	9	2025-06-10 05:46:47.807946	2025-06-10 06:30:47.807946	\N	completed	9
27103	14	345.00	8	2025-06-10 09:39:47.807946	2025-06-10 10:29:47.807946	\N	completed	3
27104	7	405.00	5	2025-06-10 09:42:47.807946	2025-06-10 10:13:47.807946	\N	completed	9
27105	28	850.00	6	2025-06-10 08:33:47.807946	2025-06-10 09:02:47.807946	\N	completed	34
27106	10	315.00	4	2025-06-10 15:37:47.807946	2025-06-10 16:13:47.807946	\N	completed	32
27107	28	420.00	9	2025-06-10 09:31:47.807946	2025-06-10 10:05:47.807946	\N	completed	32
27108	15	360.00	7	2025-06-10 21:06:47.807946	2025-06-10 21:26:47.807946	\N	completed	10
27109	10	950.00	7	2025-06-10 08:13:47.807946	2025-06-10 08:54:47.807946	\N	completed	3
27110	10	550.00	9	2025-06-10 07:39:47.807946	2025-06-10 08:27:47.807946	\N	completed	34
27111	2	300.00	8	2025-06-10 10:43:47.807946	2025-06-10 11:11:47.807946	\N	completed	8
27112	14	500.00	4	2025-06-10 06:01:47.807946	2025-06-10 06:26:47.807946	\N	completed	6
27113	11	375.00	8	2025-06-10 10:00:47.807946	2025-06-10 10:32:47.807946	\N	completed	36
27114	14	270.00	5	2025-06-10 15:28:47.807946	2025-06-10 16:09:47.807946	\N	completed	3
27115	7	550.00	5	2025-06-10 08:07:47.807946	2025-06-10 08:34:47.807946	\N	completed	36
27116	15	360.00	4	2025-06-10 05:49:47.807946	2025-06-10 06:20:47.807946	\N	completed	36
27117	15	850.00	8	2025-06-10 17:37:47.807946	2025-06-10 18:22:47.807946	\N	completed	32
27118	15	495.00	6	2025-06-10 15:54:47.807946	2025-06-10 16:32:47.807946	\N	completed	10
27119	8	575.00	5	2025-06-10 17:03:47.807946	2025-06-10 17:34:47.807946	\N	completed	36
27120	7	550.00	8	2025-06-11 18:38:47.807946	2025-06-11 19:00:47.807946	\N	completed	9
27121	9	300.00	5	2025-06-11 12:08:47.807946	2025-06-11 12:30:47.807946	\N	completed	8
27122	8	360.00	8	2025-06-11 19:16:47.807946	2025-06-11 19:37:47.807946	\N	completed	1
27123	16	1000.00	7	2025-06-11 08:16:47.807946	2025-06-11 09:04:47.807946	\N	completed	11
27124	30	825.00	8	2025-06-11 08:48:47.807946	2025-06-11 09:14:47.807946	\N	completed	8
27125	28	420.00	5	2025-06-11 10:50:47.807946	2025-06-11 11:37:47.807946	\N	completed	34
27126	9	480.00	6	2025-06-11 06:05:47.807946	2025-06-11 06:41:47.807946	\N	completed	32
27127	14	675.00	5	2025-06-11 18:38:47.807946	2025-06-11 19:04:47.807946	\N	completed	8
27128	30	1000.00	4	2025-06-11 08:44:47.807946	2025-06-11 09:04:47.807946	\N	completed	3
27129	11	975.00	8	2025-06-11 16:24:47.807946	2025-06-11 17:05:47.807946	\N	completed	36
27130	12	405.00	4	2025-06-11 09:49:47.807946	2025-06-11 10:17:47.807946	\N	completed	8
27131	30	1025.00	4	2025-06-11 07:01:47.807946	2025-06-11 07:24:47.807946	\N	completed	32
27132	2	435.00	8	2025-06-11 19:00:47.807946	2025-06-11 19:36:47.807946	\N	completed	36
27133	7	480.00	8	2025-06-11 20:17:47.807946	2025-06-11 20:37:47.807946	\N	completed	34
27134	14	975.00	6	2025-06-11 07:35:47.807946	2025-06-11 08:14:47.807946	\N	completed	34
27135	28	550.00	4	2025-06-11 18:10:47.807946	2025-06-11 18:55:47.807946	\N	completed	32
27136	30	300.00	5	2025-06-11 05:45:47.807946	2025-06-11 06:17:47.807946	\N	completed	6
27137	16	405.00	6	2025-06-11 12:00:47.807946	2025-06-11 12:36:47.807946	\N	completed	8
27138	10	300.00	7	2025-06-11 22:12:47.807946	2025-06-11 22:44:47.807946	\N	completed	32
27139	16	580.00	9	2025-06-11 20:19:47.807946	2025-06-11 20:55:47.807946	\N	completed	1
27140	14	875.00	7	2025-06-11 17:08:47.807946	2025-06-11 17:33:47.807946	\N	completed	8
27141	16	390.00	8	2025-06-11 15:26:47.807946	2025-06-11 16:07:47.807946	\N	completed	11
27142	10	285.00	5	2025-06-11 19:22:47.807946	2025-06-11 19:42:47.807946	\N	completed	34
27143	2	650.00	4	2025-06-11 17:09:47.807946	2025-06-11 17:53:47.807946	\N	completed	8
27144	28	375.00	4	2025-06-12 14:39:47.807946	2025-06-12 15:10:47.807946	\N	completed	34
27145	14	375.00	7	2025-06-12 14:57:47.807946	2025-06-12 15:28:47.807946	\N	completed	6
27146	7	405.00	4	2025-06-12 10:55:47.807946	2025-06-12 11:23:47.807946	\N	completed	34
27147	10	345.00	5	2025-06-12 15:13:47.807946	2025-06-12 15:52:47.807946	\N	completed	34
27148	30	825.00	7	2025-06-12 16:03:47.807946	2025-06-12 16:37:47.807946	\N	completed	9
27149	30	380.00	9	2025-06-12 05:49:47.807946	2025-06-12 06:32:47.807946	\N	completed	8
27150	10	280.00	4	2025-06-12 05:15:47.807946	2025-06-12 06:01:47.807946	\N	completed	34
27151	28	405.00	6	2025-06-12 12:24:47.807946	2025-06-12 12:45:47.807946	\N	completed	9
27152	11	825.00	8	2025-06-12 18:28:47.807946	2025-06-12 19:08:47.807946	\N	completed	9
27153	16	465.00	4	2025-06-12 12:08:47.807946	2025-06-12 12:33:47.807946	\N	completed	9
27154	8	450.00	8	2025-06-12 11:50:47.807946	2025-06-12 12:40:47.807946	\N	completed	9
27155	11	650.00	7	2025-06-12 07:34:47.807946	2025-06-12 08:24:47.807946	\N	completed	36
27156	15	375.00	9	2025-06-12 13:29:47.807946	2025-06-12 14:15:47.807946	\N	completed	10
27157	16	500.00	7	2025-06-12 05:12:47.807946	2025-06-12 05:52:47.807946	\N	completed	3
27158	12	925.00	8	2025-06-12 18:11:47.807946	2025-06-12 18:38:47.807946	\N	completed	1
27159	9	435.00	9	2025-06-12 15:13:47.807946	2025-06-12 15:41:47.807946	\N	completed	9
27160	7	825.00	9	2025-06-12 18:59:47.807946	2025-06-12 19:39:47.807946	\N	completed	10
27161	9	390.00	6	2025-06-12 09:20:47.807946	2025-06-12 09:52:47.807946	\N	completed	6
27162	9	270.00	8	2025-06-12 10:48:47.807946	2025-06-12 11:34:47.807946	\N	completed	3
27163	10	345.00	4	2025-06-12 12:20:47.807946	2025-06-12 12:54:47.807946	\N	completed	3
27164	14	270.00	7	2025-06-12 14:45:47.807946	2025-06-12 15:24:47.807946	\N	completed	32
27165	11	255.00	8	2025-06-13 19:02:47.807946	2025-06-13 19:32:47.807946	\N	completed	9
27166	30	450.00	8	2025-06-13 14:09:47.807946	2025-06-13 14:30:47.807946	\N	completed	34
27167	28	435.00	7	2025-06-13 13:09:47.807946	2025-06-13 13:43:47.807946	\N	completed	32
27168	9	390.00	5	2025-06-13 10:28:47.807946	2025-06-13 10:50:47.807946	\N	completed	9
27169	15	435.00	4	2025-06-13 09:49:47.807946	2025-06-13 10:36:47.807946	\N	completed	34
27170	9	600.00	8	2025-06-13 22:58:47.807946	2025-06-13 23:23:47.807946	\N	completed	6
27171	7	800.00	9	2025-06-13 08:21:47.807946	2025-06-13 09:10:47.807946	\N	completed	10
27172	28	800.00	8	2025-06-13 07:02:47.807946	2025-06-13 07:42:47.807946	\N	completed	10
27173	16	260.00	7	2025-06-13 06:09:47.807946	2025-06-13 06:42:47.807946	\N	completed	10
27174	30	775.00	6	2025-06-13 18:39:47.807946	2025-06-13 19:22:47.807946	\N	completed	8
27175	7	625.00	8	2025-06-13 07:48:47.807946	2025-06-13 08:16:47.807946	\N	completed	11
27176	15	465.00	9	2025-06-13 10:21:47.807946	2025-06-13 11:03:47.807946	\N	completed	3
27177	16	435.00	4	2025-06-13 11:08:47.807946	2025-06-13 11:42:47.807946	\N	completed	3
27178	7	270.00	8	2025-06-13 12:20:47.807946	2025-06-13 13:05:47.807946	\N	completed	1
27179	16	675.00	9	2025-06-13 08:24:47.807946	2025-06-13 09:10:47.807946	\N	completed	34
27180	15	420.00	8	2025-06-13 19:45:47.807946	2025-06-13 20:35:47.807946	\N	completed	9
27181	12	375.00	8	2025-06-13 14:12:47.807946	2025-06-13 14:53:47.807946	\N	completed	9
27182	7	360.00	9	2025-06-13 11:30:47.807946	2025-06-13 12:10:47.807946	\N	completed	6
27183	10	390.00	4	2025-06-13 09:26:47.807946	2025-06-13 10:07:47.807946	\N	completed	3
27184	2	580.00	5	2025-06-13 22:06:47.807946	2025-06-13 22:38:47.807946	\N	completed	32
27185	7	435.00	7	2025-06-13 15:36:47.807946	2025-06-13 16:10:47.807946	\N	completed	1
27186	28	450.00	8	2025-06-13 12:44:47.807946	2025-06-13 13:13:47.807946	\N	completed	6
27187	16	300.00	7	2025-06-13 20:55:47.807946	2025-06-13 21:21:47.807946	\N	completed	34
27188	2	440.00	7	2025-06-13 22:50:47.807946	2025-06-13 23:18:47.807946	\N	completed	36
27189	12	650.00	4	2025-06-13 08:12:47.807946	2025-06-13 08:46:47.807946	\N	completed	9
27190	30	420.00	8	2025-06-13 11:06:47.807946	2025-06-13 11:27:47.807946	\N	completed	11
27191	7	525.00	6	2025-06-13 14:22:47.807946	2025-06-13 15:12:47.807946	\N	completed	32
27192	15	775.00	7	2025-06-13 08:45:47.807946	2025-06-13 09:27:47.807946	\N	completed	34
27193	11	320.00	6	2025-06-13 20:11:47.807946	2025-06-13 20:45:47.807946	\N	completed	11
27194	28	320.00	6	2025-06-13 20:23:47.807946	2025-06-13 21:02:47.807946	\N	completed	3
27195	7	575.00	4	2025-06-14 07:33:47.807946	2025-06-14 08:14:47.807946	\N	completed	10
27196	8	725.00	6	2025-06-14 07:35:47.807946	2025-06-14 08:24:47.807946	\N	completed	32
27197	2	925.00	6	2025-06-14 18:07:47.807946	2025-06-14 18:30:47.807946	\N	completed	6
27198	2	340.00	4	2025-06-14 22:45:47.807946	2025-06-14 23:12:47.807946	\N	completed	1
27199	28	600.00	7	2025-06-14 17:46:47.807946	2025-06-14 18:28:47.807946	\N	completed	1
27200	11	495.00	8	2025-06-14 11:05:47.807946	2025-06-14 11:34:47.807946	\N	completed	10
27201	2	285.00	5	2025-06-14 10:24:47.807946	2025-06-14 10:50:47.807946	\N	completed	10
27202	11	725.00	8	2025-06-14 16:38:47.807946	2025-06-14 17:14:47.807946	\N	completed	1
27203	11	750.00	6	2025-06-14 18:51:47.807946	2025-06-14 19:11:47.807946	\N	completed	6
27204	16	600.00	7	2025-06-14 16:31:47.807946	2025-06-14 17:11:47.807946	\N	completed	6
27205	10	380.00	6	2025-06-14 22:33:47.807946	2025-06-14 23:07:47.807946	\N	completed	34
27206	14	750.00	9	2025-06-14 08:01:47.807946	2025-06-14 08:41:47.807946	\N	completed	3
27207	28	360.00	6	2025-06-14 22:48:47.807946	2025-06-14 23:22:47.807946	\N	completed	10
27208	14	750.00	9	2025-06-14 16:54:47.807946	2025-06-14 17:21:47.807946	\N	completed	8
27209	14	500.00	6	2025-06-15 05:17:47.807946	2025-06-15 05:49:47.807946	\N	completed	34
27210	15	285.00	6	2025-06-15 14:44:47.807946	2025-06-15 15:34:47.807946	\N	completed	1
27211	16	600.00	5	2025-06-15 08:42:47.807946	2025-06-15 09:20:47.807946	\N	completed	34
27212	12	420.00	9	2025-06-15 14:36:47.807946	2025-06-15 15:19:47.807946	\N	completed	9
27213	28	975.00	9	2025-06-15 17:29:47.807946	2025-06-15 17:56:47.807946	\N	completed	32
27214	14	580.00	6	2025-06-15 20:15:47.807946	2025-06-15 20:49:47.807946	\N	completed	9
27215	8	775.00	9	2025-06-15 18:20:47.807946	2025-06-15 18:47:47.807946	\N	completed	6
27216	8	875.00	5	2025-06-15 08:20:47.807946	2025-06-15 09:01:47.807946	\N	completed	9
27217	7	1000.00	9	2025-06-15 16:25:47.807946	2025-06-15 17:12:47.807946	\N	completed	1
27218	9	495.00	4	2025-06-15 13:42:47.807946	2025-06-15 14:04:47.807946	\N	completed	3
27219	8	340.00	8	2025-06-15 21:16:47.807946	2025-06-15 21:47:47.807946	\N	completed	1
27220	15	480.00	4	2025-06-15 21:50:47.807946	2025-06-15 22:19:47.807946	\N	completed	6
27221	8	460.00	4	2025-06-15 22:53:47.807946	2025-06-15 23:29:47.807946	\N	completed	11
27222	28	330.00	7	2025-06-15 09:09:47.807946	2025-06-15 09:47:47.807946	\N	completed	32
27223	2	510.00	6	2025-06-15 09:23:47.807946	2025-06-15 09:47:47.807946	\N	completed	1
27224	28	400.00	6	2025-06-16 05:15:47.807946	2025-06-16 05:40:47.807946	\N	completed	32
27225	30	450.00	9	2025-06-16 13:03:47.807946	2025-06-16 13:45:47.807946	\N	completed	10
27226	16	375.00	9	2025-06-16 14:02:47.807946	2025-06-16 14:32:47.807946	\N	completed	3
27227	9	360.00	9	2025-06-16 21:16:47.807946	2025-06-16 21:41:47.807946	\N	completed	36
27228	16	510.00	5	2025-06-16 14:09:47.807946	2025-06-16 14:48:47.807946	\N	completed	1
27229	7	450.00	6	2025-06-16 15:10:47.807946	2025-06-16 15:35:47.807946	\N	completed	6
27230	11	1025.00	5	2025-06-16 07:14:47.807946	2025-06-16 07:59:47.807946	\N	completed	8
27231	7	320.00	5	2025-06-16 06:37:47.807946	2025-06-16 07:14:47.807946	\N	completed	1
27232	30	480.00	8	2025-06-16 06:25:47.807946	2025-06-16 06:58:47.807946	\N	completed	32
27233	28	390.00	6	2025-06-16 11:15:47.807946	2025-06-16 11:48:47.807946	\N	completed	3
27234	14	260.00	4	2025-06-16 05:09:47.807946	2025-06-16 05:30:47.807946	\N	completed	11
27235	9	580.00	9	2025-06-16 21:05:47.807946	2025-06-16 21:27:47.807946	\N	completed	32
27236	2	500.00	9	2025-06-16 21:11:47.807946	2025-06-16 21:39:47.807946	\N	completed	6
27237	16	975.00	5	2025-06-16 17:12:47.807946	2025-06-16 17:41:47.807946	\N	completed	32
27238	10	440.00	6	2025-06-16 05:12:47.807946	2025-06-16 05:56:47.807946	\N	completed	1
27239	14	465.00	5	2025-06-16 15:13:47.807946	2025-06-16 16:02:47.807946	\N	completed	3
27240	16	800.00	7	2025-06-16 07:16:47.807946	2025-06-16 07:42:47.807946	\N	completed	9
27241	9	240.00	9	2025-06-16 19:23:47.807946	2025-06-16 20:00:47.807946	\N	completed	11
27242	16	300.00	7	2025-06-16 15:13:47.807946	2025-06-16 15:46:47.807946	\N	completed	6
27243	30	725.00	4	2025-06-16 08:58:47.807946	2025-06-16 09:40:47.807946	\N	completed	34
27244	9	550.00	5	2025-06-16 08:35:47.807946	2025-06-16 08:58:47.807946	\N	completed	11
27245	10	725.00	6	2025-06-17 16:01:47.807946	2025-06-17 16:33:47.807946	\N	completed	34
27246	28	850.00	5	2025-06-17 18:10:47.807946	2025-06-17 18:44:47.807946	\N	completed	11
27247	10	345.00	9	2025-06-17 19:30:47.807946	2025-06-17 20:12:47.807946	\N	completed	32
27248	30	440.00	6	2025-06-17 21:20:47.807946	2025-06-17 22:09:47.807946	\N	completed	1
27249	15	975.00	4	2025-06-17 16:50:47.807946	2025-06-17 17:29:47.807946	\N	completed	9
27250	7	435.00	9	2025-06-17 12:31:47.807946	2025-06-17 13:01:47.807946	\N	completed	1
27251	12	650.00	7	2025-06-17 17:40:47.807946	2025-06-17 18:15:47.807946	\N	completed	11
27252	2	405.00	7	2025-06-17 15:07:47.807946	2025-06-17 15:53:47.807946	\N	completed	6
27253	8	825.00	4	2025-06-17 07:41:47.807946	2025-06-17 08:31:47.807946	\N	completed	10
27254	14	450.00	6	2025-06-17 13:59:47.807946	2025-06-17 14:25:47.807946	\N	completed	1
27255	9	1025.00	5	2025-06-17 17:10:47.807946	2025-06-17 17:48:47.807946	\N	completed	10
27256	9	520.00	7	2025-06-17 22:36:47.807946	2025-06-17 23:16:47.807946	\N	completed	34
27257	16	390.00	8	2025-06-17 10:04:47.807946	2025-06-17 10:34:47.807946	\N	completed	11
27258	30	375.00	7	2025-06-17 11:23:47.807946	2025-06-17 12:13:47.807946	\N	completed	11
27259	8	725.00	7	2025-06-17 16:07:47.807946	2025-06-17 16:32:47.807946	\N	completed	11
27260	2	700.00	8	2025-06-17 08:48:47.807946	2025-06-17 09:19:47.807946	\N	completed	9
27261	16	950.00	6	2025-06-17 18:03:47.807946	2025-06-17 18:34:47.807946	\N	completed	6
27262	11	575.00	4	2025-06-18 18:41:47.807946	2025-06-18 19:12:47.807946	\N	completed	6
27263	2	420.00	7	2025-06-18 06:55:47.807946	2025-06-18 07:27:47.807946	\N	completed	11
27264	8	380.00	8	2025-06-18 21:15:47.807946	2025-06-18 22:01:47.807946	\N	completed	34
27265	7	975.00	5	2025-06-18 08:21:47.807946	2025-06-18 09:01:47.807946	\N	completed	32
27266	30	510.00	8	2025-06-18 10:54:47.807946	2025-06-18 11:33:47.807946	\N	completed	34
27267	30	480.00	4	2025-06-18 11:09:47.807946	2025-06-18 11:50:47.807946	\N	completed	6
27268	10	390.00	7	2025-06-18 15:12:47.807946	2025-06-18 15:42:47.807946	\N	completed	10
27269	7	465.00	5	2025-06-18 09:25:47.807946	2025-06-18 09:55:47.807946	\N	completed	11
27270	28	525.00	8	2025-06-18 17:29:47.807946	2025-06-18 18:09:47.807946	\N	completed	11
27271	30	675.00	9	2025-06-18 17:28:47.807946	2025-06-18 17:53:47.807946	\N	completed	10
27272	28	330.00	7	2025-06-18 10:29:47.807946	2025-06-18 11:01:47.807946	\N	completed	9
27273	10	750.00	6	2025-06-18 17:25:47.807946	2025-06-18 18:02:47.807946	\N	completed	8
27274	2	725.00	5	2025-06-18 08:44:47.807946	2025-06-18 09:25:47.807946	\N	completed	11
27275	28	495.00	7	2025-06-18 09:00:47.807946	2025-06-18 09:46:47.807946	\N	completed	36
27276	14	360.00	6	2025-06-18 11:29:47.807946	2025-06-18 12:13:47.807946	\N	completed	10
27277	8	300.00	5	2025-06-18 15:52:47.807946	2025-06-18 16:36:47.807946	\N	completed	3
27278	15	750.00	6	2025-06-18 07:45:47.807946	2025-06-18 08:27:47.807946	\N	completed	11
27279	7	450.00	5	2025-06-18 09:16:47.807946	2025-06-18 09:40:47.807946	\N	completed	10
27280	30	450.00	4	2025-06-19 15:35:47.807946	2025-06-19 16:04:47.807946	\N	completed	10
27281	16	725.00	9	2025-06-19 08:41:47.807946	2025-06-19 09:30:47.807946	\N	completed	32
27282	2	300.00	9	2025-06-19 19:16:47.807946	2025-06-19 19:54:47.807946	\N	completed	6
27283	9	345.00	7	2025-06-19 19:18:47.807946	2025-06-19 19:53:47.807946	\N	completed	36
27284	7	975.00	5	2025-06-19 17:35:47.807946	2025-06-19 18:07:47.807946	\N	completed	9
27285	15	400.00	6	2025-06-19 06:59:47.807946	2025-06-19 07:40:47.807946	\N	completed	6
27286	15	825.00	6	2025-06-19 07:31:47.807946	2025-06-19 08:06:47.807946	\N	completed	36
27287	16	510.00	4	2025-06-19 13:50:47.807946	2025-06-19 14:30:47.807946	\N	completed	8
27288	10	650.00	6	2025-06-19 16:22:47.807946	2025-06-19 17:02:47.807946	\N	completed	6
27289	8	300.00	7	2025-06-19 09:31:47.807946	2025-06-19 09:52:47.807946	\N	completed	8
27290	30	460.00	5	2025-06-19 06:04:47.807946	2025-06-19 06:50:47.807946	\N	completed	9
27291	8	330.00	7	2025-06-19 11:10:47.807946	2025-06-19 11:50:47.807946	\N	completed	6
27292	10	340.00	4	2025-06-19 05:44:47.807946	2025-06-19 06:27:47.807946	\N	completed	34
27293	8	285.00	9	2025-06-19 11:41:47.807946	2025-06-19 12:07:47.807946	\N	completed	6
27294	28	300.00	7	2025-06-19 15:18:47.807946	2025-06-19 15:48:47.807946	\N	completed	34
27295	16	270.00	5	2025-06-19 19:56:47.807946	2025-06-19 20:16:47.807946	\N	completed	8
27296	14	800.00	9	2025-06-19 08:01:47.807946	2025-06-19 08:45:47.807946	\N	completed	6
27297	2	900.00	7	2025-06-19 18:23:47.807946	2025-06-19 19:00:47.807946	\N	completed	1
27298	8	460.00	8	2025-06-19 06:09:47.807946	2025-06-19 06:36:47.807946	\N	completed	36
27299	12	340.00	4	2025-06-20 22:36:47.807946	2025-06-20 23:17:47.807946	\N	completed	6
27300	28	375.00	8	2025-06-20 13:32:47.807946	2025-06-20 14:01:47.807946	\N	completed	34
27301	7	925.00	8	2025-06-20 08:20:47.807946	2025-06-20 09:00:47.807946	\N	completed	11
27302	12	675.00	8	2025-06-20 08:23:47.807946	2025-06-20 09:08:47.807946	\N	completed	11
27303	9	380.00	7	2025-06-20 22:34:47.807946	2025-06-20 23:13:47.807946	\N	completed	6
27304	7	925.00	6	2025-06-20 07:27:47.807946	2025-06-20 08:12:47.807946	\N	completed	32
27305	12	450.00	7	2025-06-20 09:29:47.807946	2025-06-20 10:13:47.807946	\N	completed	11
27306	10	975.00	4	2025-06-20 18:58:47.807946	2025-06-20 19:34:47.807946	\N	completed	8
27307	30	480.00	9	2025-06-20 22:07:47.807946	2025-06-20 22:49:47.807946	\N	completed	1
27308	30	450.00	9	2025-06-20 10:51:47.807946	2025-06-20 11:12:47.807946	\N	completed	11
27309	30	380.00	5	2025-06-20 22:09:47.807946	2025-06-20 22:42:47.807946	\N	completed	6
27310	30	240.00	6	2025-06-20 19:17:47.807946	2025-06-20 19:41:47.807946	\N	completed	36
27311	10	440.00	4	2025-06-20 06:53:47.807946	2025-06-20 07:42:47.807946	\N	completed	10
27312	2	460.00	9	2025-06-20 21:36:47.807946	2025-06-20 21:57:47.807946	\N	completed	36
27313	9	500.00	6	2025-06-20 21:16:47.807946	2025-06-20 21:44:47.807946	\N	completed	8
27314	16	525.00	9	2025-06-20 13:20:47.807946	2025-06-20 13:43:47.807946	\N	completed	32
27315	30	300.00	6	2025-06-20 09:47:47.807946	2025-06-20 10:26:47.807946	\N	completed	34
27316	8	330.00	7	2025-06-20 14:09:47.807946	2025-06-20 14:42:47.807946	\N	completed	32
27317	2	700.00	6	2025-06-20 07:11:47.807946	2025-06-20 07:52:47.807946	\N	completed	34
27318	30	450.00	6	2025-06-20 19:05:47.807946	2025-06-20 19:33:47.807946	\N	completed	8
27319	11	500.00	5	2025-06-20 22:13:47.807946	2025-06-20 22:56:47.807946	\N	completed	34
27320	8	775.00	4	2025-06-20 16:14:47.807946	2025-06-20 16:56:47.807946	\N	completed	6
27321	16	270.00	8	2025-06-20 11:38:47.807946	2025-06-20 12:19:47.807946	\N	completed	34
27322	8	420.00	4	2025-06-20 10:45:47.807946	2025-06-20 11:19:47.807946	\N	completed	34
27323	12	345.00	8	2025-06-20 12:38:47.807946	2025-06-20 12:59:47.807946	\N	completed	9
27324	15	875.00	5	2025-06-20 16:20:47.807946	2025-06-20 16:48:47.807946	\N	completed	3
27325	8	280.00	5	2025-06-20 05:14:47.807946	2025-06-20 05:46:47.807946	\N	completed	8
27326	12	340.00	7	2025-06-20 06:17:47.807946	2025-06-20 06:43:47.807946	\N	completed	32
27327	16	495.00	4	2025-06-21 10:51:47.807946	2025-06-21 11:40:47.807946	\N	completed	34
27328	14	360.00	4	2025-06-21 14:17:47.807946	2025-06-21 14:38:47.807946	\N	completed	8
27329	10	420.00	7	2025-06-21 05:15:47.807946	2025-06-21 05:40:47.807946	\N	completed	3
27330	2	925.00	8	2025-06-21 18:22:47.807946	2025-06-21 19:03:47.807946	\N	completed	34
27331	30	390.00	6	2025-06-21 15:58:47.807946	2025-06-21 16:36:47.807946	\N	completed	11
27332	11	280.00	6	2025-06-21 05:29:47.807946	2025-06-21 06:07:47.807946	\N	completed	36
27333	12	465.00	6	2025-06-21 12:03:47.807946	2025-06-21 12:28:47.807946	\N	completed	6
27334	30	850.00	5	2025-06-21 08:56:47.807946	2025-06-21 09:26:47.807946	\N	completed	8
27335	28	800.00	9	2025-06-21 17:22:47.807946	2025-06-21 17:51:47.807946	\N	completed	1
27336	16	460.00	6	2025-06-21 20:59:47.807946	2025-06-21 21:32:47.807946	\N	completed	10
27337	16	420.00	8	2025-06-21 19:37:47.807946	2025-06-21 20:24:47.807946	\N	completed	1
27338	9	510.00	8	2025-06-21 09:23:47.807946	2025-06-21 10:10:47.807946	\N	completed	11
27339	9	300.00	4	2025-06-21 05:35:47.807946	2025-06-21 06:24:47.807946	\N	completed	11
27340	12	360.00	6	2025-06-21 19:04:47.807946	2025-06-21 19:24:47.807946	\N	completed	34
27341	28	390.00	5	2025-06-21 19:44:47.807946	2025-06-21 20:20:47.807946	\N	completed	10
27342	11	345.00	6	2025-06-21 10:36:47.807946	2025-06-21 11:26:47.807946	\N	completed	10
27343	2	300.00	5	2025-06-21 10:40:47.807946	2025-06-21 11:06:47.807946	\N	completed	1
27344	14	405.00	6	2025-06-21 14:51:47.807946	2025-06-21 15:14:47.807946	\N	completed	10
27345	11	270.00	7	2025-06-21 15:38:47.807946	2025-06-21 16:00:47.807946	\N	completed	6
27346	14	520.00	8	2025-06-21 20:03:47.807946	2025-06-21 20:26:47.807946	\N	completed	9
27347	8	405.00	4	2025-06-21 09:29:47.807946	2025-06-21 10:02:47.807946	\N	completed	36
27348	11	340.00	9	2025-06-21 20:26:47.807946	2025-06-21 20:46:47.807946	\N	completed	32
27349	7	600.00	4	2025-06-21 21:18:47.807946	2025-06-21 21:44:47.807946	\N	completed	1
27350	28	900.00	9	2025-06-22 08:45:47.807946	2025-06-22 09:16:47.807946	\N	completed	9
27351	7	575.00	9	2025-06-22 07:30:47.807946	2025-06-22 07:54:47.807946	\N	completed	32
27352	28	300.00	6	2025-06-22 13:45:47.807946	2025-06-22 14:17:47.807946	\N	completed	11
27353	15	575.00	6	2025-06-22 17:02:47.807946	2025-06-22 17:48:47.807946	\N	completed	36
27354	15	360.00	6	2025-06-22 11:47:47.807946	2025-06-22 12:21:47.807946	\N	completed	36
27355	11	1000.00	5	2025-06-22 17:19:47.807946	2025-06-22 17:55:47.807946	\N	completed	36
27356	10	775.00	7	2025-06-22 18:49:47.807946	2025-06-22 19:22:47.807946	\N	completed	11
27357	15	575.00	5	2025-06-22 17:11:47.807946	2025-06-22 17:35:47.807946	\N	completed	9
27358	15	390.00	7	2025-06-22 09:55:47.807946	2025-06-22 10:36:47.807946	\N	completed	32
27359	8	360.00	9	2025-06-22 10:01:47.807946	2025-06-22 10:29:47.807946	\N	completed	32
27360	12	600.00	9	2025-06-22 20:29:47.807946	2025-06-22 21:09:47.807946	\N	completed	8
27361	7	320.00	4	2025-06-22 20:59:47.807946	2025-06-22 21:19:47.807946	\N	completed	32
27362	8	340.00	5	2025-06-22 22:17:47.807946	2025-06-22 22:53:47.807946	\N	completed	3
27363	7	315.00	4	2025-06-22 09:51:47.807946	2025-06-22 10:26:47.807946	\N	completed	3
27364	11	750.00	6	2025-06-22 18:05:47.807946	2025-06-22 18:46:47.807946	\N	completed	3
27365	11	925.00	5	2025-06-22 07:08:47.807946	2025-06-22 07:31:47.807946	\N	completed	6
27366	9	925.00	8	2025-06-23 18:02:47.807946	2025-06-23 18:50:47.807946	\N	completed	36
27367	11	650.00	8	2025-06-23 17:56:47.807946	2025-06-23 18:39:47.807946	\N	completed	9
27368	16	510.00	6	2025-06-23 11:54:47.807946	2025-06-23 12:35:47.807946	\N	completed	36
27369	7	345.00	9	2025-06-23 12:20:47.807946	2025-06-23 12:42:47.807946	\N	completed	11
27370	2	315.00	5	2025-06-23 13:30:47.807946	2025-06-23 13:52:47.807946	\N	completed	34
27371	30	285.00	5	2025-06-23 19:36:47.807946	2025-06-23 20:20:47.807946	\N	completed	8
27372	28	300.00	5	2025-06-23 06:15:47.807946	2025-06-23 06:44:47.807946	\N	completed	6
27373	28	950.00	9	2025-06-23 08:07:47.807946	2025-06-23 08:37:47.807946	\N	completed	32
27374	7	420.00	6	2025-06-23 14:44:47.807946	2025-06-23 15:16:47.807946	\N	completed	34
27375	14	420.00	6	2025-06-23 12:41:47.807946	2025-06-23 13:06:47.807946	\N	completed	6
27376	12	440.00	5	2025-06-23 05:07:47.807946	2025-06-23 05:33:47.807946	\N	completed	8
27377	9	285.00	7	2025-06-23 13:35:47.807946	2025-06-23 14:25:47.807946	\N	completed	8
27378	30	495.00	5	2025-06-23 15:53:47.807946	2025-06-23 16:31:47.807946	\N	completed	36
27379	7	575.00	7	2025-06-23 16:11:47.807946	2025-06-23 17:01:47.807946	\N	completed	8
27380	28	300.00	4	2025-06-23 11:06:47.807946	2025-06-23 11:50:47.807946	\N	completed	1
27381	2	480.00	4	2025-06-23 15:38:47.807946	2025-06-23 16:25:47.807946	\N	completed	6
27382	15	1000.00	4	2025-06-23 18:27:47.807946	2025-06-23 19:16:47.807946	\N	completed	1
27383	9	420.00	5	2025-06-23 12:47:47.807946	2025-06-23 13:15:47.807946	\N	completed	34
27384	16	975.00	4	2025-06-23 18:07:47.807946	2025-06-23 18:57:47.807946	\N	completed	3
27385	10	300.00	5	2025-06-23 19:24:47.807946	2025-06-23 19:49:47.807946	\N	completed	8
27386	28	435.00	5	2025-06-23 09:48:47.807946	2025-06-23 10:26:47.807946	\N	completed	6
27387	7	925.00	6	2025-06-23 16:27:47.807946	2025-06-23 17:03:47.807946	\N	completed	8
27388	2	480.00	9	2025-06-23 06:43:47.807946	2025-06-23 07:04:47.807946	\N	completed	8
27389	8	360.00	9	2025-06-23 06:26:47.807946	2025-06-23 06:52:47.807946	\N	completed	1
27390	30	465.00	6	2025-06-23 15:16:47.807946	2025-06-23 15:37:47.807946	\N	completed	10
27391	15	375.00	6	2025-06-23 11:44:47.807946	2025-06-23 12:16:47.807946	\N	completed	10
27392	14	480.00	5	2025-06-23 06:39:47.807946	2025-06-23 07:08:47.807946	\N	completed	3
27393	10	750.00	7	2025-06-23 16:13:47.807946	2025-06-23 16:46:47.807946	\N	completed	6
27394	14	360.00	5	2025-06-24 09:08:47.807946	2025-06-24 09:29:47.807946	\N	completed	32
27395	9	600.00	7	2025-06-24 18:17:47.807946	2025-06-24 18:57:47.807946	\N	completed	1
27396	16	405.00	7	2025-06-24 19:55:47.807946	2025-06-24 20:45:47.807946	\N	completed	11
27397	8	725.00	9	2025-06-24 16:02:47.807946	2025-06-24 16:45:47.807946	\N	completed	9
27398	9	775.00	6	2025-06-24 18:57:47.807946	2025-06-24 19:26:47.807946	\N	completed	8
27399	16	510.00	8	2025-06-24 10:24:47.807946	2025-06-24 10:45:47.807946	\N	completed	8
27400	14	465.00	5	2025-06-24 14:41:47.807946	2025-06-24 15:25:47.807946	\N	completed	6
27401	10	405.00	4	2025-06-24 10:15:47.807946	2025-06-24 11:05:47.807946	\N	completed	36
27402	11	650.00	4	2025-06-24 18:31:47.807946	2025-06-24 19:18:47.807946	\N	completed	11
27403	15	500.00	9	2025-06-24 21:16:47.807946	2025-06-24 21:57:47.807946	\N	completed	10
27404	15	285.00	9	2025-06-24 15:11:47.807946	2025-06-24 15:36:47.807946	\N	completed	32
27405	9	420.00	8	2025-06-24 06:48:47.807946	2025-06-24 07:27:47.807946	\N	completed	3
27406	15	420.00	9	2025-06-24 19:14:47.807946	2025-06-24 19:53:47.807946	\N	completed	11
27407	9	850.00	4	2025-06-24 18:32:47.807946	2025-06-24 19:21:47.807946	\N	completed	32
27408	16	775.00	7	2025-06-24 08:26:47.807946	2025-06-24 08:59:47.807946	\N	completed	8
27409	16	270.00	7	2025-06-24 15:28:47.807946	2025-06-24 16:15:47.807946	\N	completed	36
27410	30	440.00	4	2025-06-24 22:40:47.807946	2025-06-24 23:11:47.807946	\N	completed	10
27411	15	420.00	8	2025-06-24 09:16:47.807946	2025-06-24 09:39:47.807946	\N	completed	36
27412	9	510.00	8	2025-06-24 12:03:47.807946	2025-06-24 12:38:47.807946	\N	completed	10
27413	11	525.00	5	2025-06-24 09:22:47.807946	2025-06-24 10:12:47.807946	\N	completed	6
27414	11	700.00	8	2025-06-25 17:24:47.807946	2025-06-25 17:50:47.807946	\N	completed	11
27415	28	420.00	4	2025-06-25 05:45:47.807946	2025-06-25 06:16:47.807946	\N	completed	3
27416	15	560.00	5	2025-06-25 22:02:47.807946	2025-06-25 22:50:47.807946	\N	completed	1
27417	30	775.00	4	2025-06-25 07:07:47.807946	2025-06-25 07:56:47.807946	\N	completed	36
27418	11	330.00	5	2025-06-25 19:22:47.807946	2025-06-25 19:49:47.807946	\N	completed	10
27419	8	625.00	9	2025-06-25 07:28:47.807946	2025-06-25 08:08:47.807946	\N	completed	36
27420	15	315.00	9	2025-06-25 15:16:47.807946	2025-06-25 15:39:47.807946	\N	completed	34
27421	11	420.00	7	2025-06-25 14:27:47.807946	2025-06-25 14:53:47.807946	\N	completed	9
27422	10	675.00	7	2025-06-25 17:00:47.807946	2025-06-25 17:35:47.807946	\N	completed	1
27423	28	435.00	9	2025-06-25 12:20:47.807946	2025-06-25 12:49:47.807946	\N	completed	1
27424	7	900.00	7	2025-06-25 17:19:47.807946	2025-06-25 17:47:47.807946	\N	completed	3
27425	9	400.00	9	2025-06-25 20:37:47.807946	2025-06-25 21:02:47.807946	\N	completed	1
27426	2	375.00	5	2025-06-25 10:51:47.807946	2025-06-25 11:27:47.807946	\N	completed	9
27427	14	380.00	5	2025-06-25 20:25:47.807946	2025-06-25 21:06:47.807946	\N	completed	36
27428	15	340.00	9	2025-06-25 22:31:47.807946	2025-06-25 23:16:47.807946	\N	completed	6
27429	30	950.00	5	2025-06-25 07:57:47.807946	2025-06-25 08:29:47.807946	\N	completed	10
27430	7	975.00	9	2025-06-26 16:40:47.807946	2025-06-26 17:00:47.807946	\N	completed	3
27431	15	375.00	8	2025-06-26 12:45:47.807946	2025-06-26 13:24:47.807946	\N	completed	11
27432	7	405.00	5	2025-06-26 12:54:47.807946	2025-06-26 13:39:47.807946	\N	completed	8
27433	28	750.00	6	2025-06-26 17:33:47.807946	2025-06-26 18:12:47.807946	\N	completed	8
27434	16	575.00	4	2025-06-26 08:35:47.807946	2025-06-26 09:15:47.807946	\N	completed	32
27435	11	405.00	8	2025-06-26 09:24:47.807946	2025-06-26 10:06:47.807946	\N	completed	9
27436	16	495.00	8	2025-06-26 13:30:47.807946	2025-06-26 13:56:47.807946	\N	completed	11
27437	30	375.00	5	2025-06-26 10:21:47.807946	2025-06-26 10:59:47.807946	\N	completed	1
27438	15	480.00	8	2025-06-26 09:28:47.807946	2025-06-26 10:07:47.807946	\N	completed	34
27439	14	800.00	7	2025-06-26 17:47:47.807946	2025-06-26 18:36:47.807946	\N	completed	10
27440	14	360.00	9	2025-06-26 10:31:47.807946	2025-06-26 10:58:47.807946	\N	completed	34
27441	11	750.00	5	2025-06-26 17:52:47.807946	2025-06-26 18:32:47.807946	\N	completed	36
27442	10	300.00	6	2025-06-26 06:11:47.807946	2025-06-26 06:44:47.807946	\N	completed	32
27443	16	260.00	9	2025-06-26 05:47:47.807946	2025-06-26 06:13:47.807946	\N	completed	1
27444	11	500.00	9	2025-06-26 21:05:47.807946	2025-06-26 21:53:47.807946	\N	completed	11
27445	30	340.00	4	2025-06-26 05:45:47.807946	2025-06-26 06:05:47.807946	\N	completed	11
27446	9	300.00	8	2025-06-26 05:54:47.807946	2025-06-26 06:28:47.807946	\N	completed	32
27447	7	360.00	9	2025-06-26 21:41:47.807946	2025-06-26 22:15:47.807946	\N	completed	1
27448	8	495.00	8	2025-06-26 11:47:47.807946	2025-06-26 12:34:47.807946	\N	completed	1
27449	12	260.00	9	2025-06-26 06:59:47.807946	2025-06-26 07:21:47.807946	\N	completed	34
27450	11	440.00	9	2025-06-26 22:58:47.807946	2025-06-26 23:48:47.807946	\N	completed	3
27451	2	240.00	7	2025-06-26 19:58:47.807946	2025-06-26 20:48:47.807946	\N	completed	32
27452	9	925.00	7	2025-06-26 17:50:47.807946	2025-06-26 18:34:47.807946	\N	completed	34
27453	28	600.00	4	2025-06-26 18:05:47.807946	2025-06-26 18:26:47.807946	\N	completed	1
27454	16	405.00	9	2025-06-26 19:05:47.807946	2025-06-26 19:30:47.807946	\N	completed	36
27455	11	510.00	4	2025-06-26 14:43:47.807946	2025-06-26 15:05:47.807946	\N	completed	8
27456	9	435.00	5	2025-06-26 09:00:47.807946	2025-06-26 09:27:47.807946	\N	completed	36
27457	11	285.00	8	2025-06-26 12:48:47.807946	2025-06-26 13:35:47.807946	\N	completed	32
27458	14	330.00	7	2025-06-26 11:50:47.807946	2025-06-26 12:35:47.807946	\N	completed	11
27459	9	360.00	7	2025-06-26 21:37:47.807946	2025-06-26 21:57:47.807946	\N	completed	9
27460	12	900.00	5	2025-06-26 07:26:47.807946	2025-06-26 08:00:47.807946	\N	completed	8
27461	7	480.00	7	2025-06-27 22:08:47.807946	2025-06-27 22:43:47.807946	\N	completed	3
27462	28	300.00	4	2025-06-27 09:44:47.807946	2025-06-27 10:31:47.807946	\N	completed	34
27463	16	390.00	4	2025-06-27 14:52:47.807946	2025-06-27 15:25:47.807946	\N	completed	8
27464	16	345.00	9	2025-06-27 14:05:47.807946	2025-06-27 14:37:47.807946	\N	completed	32
27465	8	315.00	9	2025-06-27 15:04:47.807946	2025-06-27 15:24:47.807946	\N	completed	3
27466	10	520.00	7	2025-06-27 21:33:47.807946	2025-06-27 22:16:47.807946	\N	completed	9
27467	7	825.00	7	2025-06-27 16:05:47.807946	2025-06-27 16:32:47.807946	\N	completed	3
27468	30	390.00	7	2025-06-27 11:17:47.807946	2025-06-27 11:37:47.807946	\N	completed	8
27469	28	300.00	6	2025-06-27 09:38:47.807946	2025-06-27 10:26:47.807946	\N	completed	3
27470	28	300.00	9	2025-06-27 09:11:47.807946	2025-06-27 09:49:47.807946	\N	completed	32
27471	16	345.00	7	2025-06-27 12:27:47.807946	2025-06-27 12:48:47.807946	\N	completed	34
27472	10	450.00	4	2025-06-27 11:08:47.807946	2025-06-27 11:53:47.807946	\N	completed	11
27473	2	440.00	9	2025-06-27 05:40:47.807946	2025-06-27 06:29:47.807946	\N	completed	36
27474	16	510.00	7	2025-06-27 13:28:47.807946	2025-06-27 14:12:47.807946	\N	completed	6
27475	2	320.00	8	2025-06-27 05:45:47.807946	2025-06-27 06:22:47.807946	\N	completed	34
27476	14	525.00	9	2025-06-27 17:21:47.807946	2025-06-27 18:06:47.807946	\N	completed	34
27477	2	525.00	4	2025-06-27 11:47:47.807946	2025-06-27 12:30:47.807946	\N	completed	32
27478	30	750.00	7	2025-06-27 07:24:47.807946	2025-06-27 07:47:47.807946	\N	completed	6
27479	7	300.00	4	2025-06-27 06:36:47.807946	2025-06-27 07:05:47.807946	\N	completed	3
27480	14	315.00	8	2025-06-27 10:18:47.807946	2025-06-27 11:02:47.807946	\N	completed	6
27481	14	300.00	6	2025-06-27 13:29:47.807946	2025-06-27 14:14:47.807946	\N	completed	9
27482	16	900.00	7	2025-06-27 17:48:47.807946	2025-06-27 18:37:47.807946	\N	completed	8
27483	9	330.00	9	2025-06-27 14:25:47.807946	2025-06-27 15:07:47.807946	\N	completed	34
27484	30	435.00	6	2025-06-27 09:41:47.807946	2025-06-27 10:13:47.807946	\N	completed	9
27485	16	270.00	8	2025-06-27 10:19:47.807946	2025-06-27 10:45:47.807946	\N	completed	34
27486	7	375.00	8	2025-06-27 12:37:47.807946	2025-06-27 13:22:47.807946	\N	completed	11
27487	8	435.00	6	2025-06-27 15:38:47.807946	2025-06-27 16:23:47.807946	\N	completed	1
27488	7	435.00	8	2025-06-27 11:14:47.807946	2025-06-27 12:02:47.807946	\N	completed	6
27489	2	420.00	8	2025-06-27 10:54:47.807946	2025-06-27 11:34:47.807946	\N	completed	8
27490	8	405.00	9	2025-06-28 14:03:47.807946	2025-06-28 14:31:47.807946	\N	completed	36
27491	16	345.00	8	2025-06-28 14:02:47.807946	2025-06-28 14:39:47.807946	\N	completed	32
27492	10	510.00	9	2025-06-28 15:33:47.807946	2025-06-28 16:02:47.807946	\N	completed	32
27493	12	900.00	6	2025-06-28 17:31:47.807946	2025-06-28 18:10:47.807946	\N	completed	32
27494	28	825.00	9	2025-06-28 07:35:47.807946	2025-06-28 07:57:47.807946	\N	completed	10
27495	8	1025.00	9	2025-06-28 16:26:47.807946	2025-06-28 17:02:47.807946	\N	completed	3
27496	30	460.00	6	2025-06-28 20:47:47.807946	2025-06-28 21:10:47.807946	\N	completed	32
27497	7	405.00	4	2025-06-28 19:31:47.807946	2025-06-28 20:10:47.807946	\N	completed	8
27498	8	270.00	6	2025-06-28 12:57:47.807946	2025-06-28 13:46:47.807946	\N	completed	32
27499	28	420.00	4	2025-06-28 19:33:47.807946	2025-06-28 19:58:47.807946	\N	completed	1
27500	30	270.00	4	2025-06-28 13:24:47.807946	2025-06-28 14:12:47.807946	\N	completed	32
27501	7	510.00	4	2025-06-28 11:34:47.807946	2025-06-28 11:59:47.807946	\N	completed	8
27502	14	340.00	7	2025-06-28 06:40:47.807946	2025-06-28 07:08:47.807946	\N	completed	8
27503	16	405.00	6	2025-06-28 19:58:47.807946	2025-06-28 20:38:47.807946	\N	completed	11
27504	30	390.00	8	2025-06-28 10:53:47.807946	2025-06-28 11:38:47.807946	\N	completed	6
27505	7	380.00	5	2025-06-28 05:53:47.807946	2025-06-28 06:34:47.807946	\N	completed	36
27506	14	420.00	6	2025-06-28 20:52:47.807946	2025-06-28 21:31:47.807946	\N	completed	10
27507	28	560.00	9	2025-06-28 21:53:47.807946	2025-06-28 22:24:47.807946	\N	completed	9
27508	8	450.00	5	2025-06-29 15:32:47.807946	2025-06-29 16:20:47.807946	\N	completed	11
27509	30	480.00	9	2025-06-29 06:37:47.807946	2025-06-29 07:09:47.807946	\N	completed	3
27510	7	560.00	5	2025-06-29 22:44:47.807946	2025-06-29 23:13:47.807946	\N	completed	9
27511	28	675.00	4	2025-06-29 18:13:47.807946	2025-06-29 18:54:47.807946	\N	completed	1
27512	12	650.00	7	2025-06-29 17:09:47.807946	2025-06-29 17:33:47.807946	\N	completed	11
27513	30	550.00	9	2025-06-29 17:52:47.807946	2025-06-29 18:20:47.807946	\N	completed	9
27514	10	450.00	9	2025-06-29 13:51:47.807946	2025-06-29 14:37:47.807946	\N	completed	1
27515	2	1025.00	7	2025-06-29 08:17:47.807946	2025-06-29 09:07:47.807946	\N	completed	36
27516	10	480.00	9	2025-06-29 05:05:47.807946	2025-06-29 05:29:47.807946	\N	completed	11
27517	16	850.00	4	2025-06-29 17:46:47.807946	2025-06-29 18:36:47.807946	\N	completed	32
27518	7	480.00	8	2025-06-29 21:58:47.807946	2025-06-29 22:30:47.807946	\N	completed	11
27519	12	525.00	6	2025-06-29 12:46:47.807946	2025-06-29 13:26:47.807946	\N	completed	6
27520	10	390.00	8	2025-06-29 13:58:47.807946	2025-06-29 14:42:47.807946	\N	completed	1
27521	28	320.00	4	2025-06-29 21:34:47.807946	2025-06-29 22:01:47.807946	\N	completed	1
27522	10	380.00	8	2025-06-29 05:51:47.807946	2025-06-29 06:21:47.807946	\N	completed	36
27523	16	320.00	4	2025-06-29 20:49:47.807946	2025-06-29 21:21:47.807946	\N	completed	6
27524	8	390.00	7	2025-06-30 11:22:47.807946	2025-06-30 12:12:47.807946	\N	completed	1
27525	28	510.00	5	2025-06-30 11:38:47.807946	2025-06-30 12:07:47.807946	\N	completed	1
27526	7	285.00	5	2025-06-30 10:06:47.807946	2025-06-30 10:47:47.807946	\N	completed	36
27527	9	285.00	6	2025-06-30 10:31:47.807946	2025-06-30 10:59:47.807946	\N	completed	32
27528	10	270.00	8	2025-06-30 10:09:47.807946	2025-06-30 10:57:47.807946	\N	completed	34
27529	15	390.00	5	2025-06-30 13:26:47.807946	2025-06-30 13:52:47.807946	\N	completed	9
27530	9	375.00	7	2025-06-30 14:36:47.807946	2025-06-30 15:13:47.807946	\N	completed	11
27531	10	360.00	5	2025-06-30 20:36:47.807946	2025-06-30 21:11:47.807946	\N	completed	36
27532	7	380.00	9	2025-06-30 06:15:47.807946	2025-06-30 06:47:47.807946	\N	completed	6
27533	15	520.00	8	2025-06-30 21:18:47.807946	2025-06-30 21:53:47.807946	\N	completed	1
27534	12	360.00	4	2025-06-30 21:09:47.807946	2025-06-30 21:50:47.807946	\N	completed	34
27535	14	420.00	7	2025-06-30 11:51:47.807946	2025-06-30 12:21:47.807946	\N	completed	9
27536	14	420.00	7	2025-06-30 20:10:47.807946	2025-06-30 20:45:47.807946	\N	completed	9
27537	16	975.00	9	2025-06-30 08:20:47.807946	2025-06-30 08:40:47.807946	\N	completed	11
27538	14	285.00	9	2025-06-30 15:56:47.807946	2025-06-30 16:16:47.807946	\N	completed	34
27539	12	330.00	8	2025-06-30 14:54:47.807946	2025-06-30 15:15:47.807946	\N	completed	36
27540	14	800.00	7	2025-06-30 17:57:47.807946	2025-06-30 18:20:47.807946	\N	completed	3
27541	7	480.00	6	2025-06-30 05:49:47.807946	2025-06-30 06:22:47.807946	\N	completed	6
27542	8	285.00	7	2025-06-30 15:32:47.807946	2025-06-30 15:53:47.807946	\N	completed	36
27543	30	440.00	9	2025-06-30 20:44:47.807946	2025-06-30 21:31:47.807946	\N	completed	1
27544	11	500.00	4	2025-06-30 05:24:47.807946	2025-06-30 05:44:47.807946	\N	completed	9
27545	11	520.00	8	2025-06-30 22:04:47.807946	2025-06-30 22:34:47.807946	\N	completed	32
27546	12	500.00	8	2025-06-30 22:16:47.807946	2025-06-30 22:46:47.807946	\N	completed	10
27547	10	625.00	7	2025-07-01 16:11:47.807946	2025-07-01 16:40:47.807946	\N	completed	11
27548	7	550.00	5	2025-07-01 18:41:47.807946	2025-07-01 19:25:47.807946	\N	completed	10
27549	14	875.00	5	2025-07-01 07:41:47.807946	2025-07-01 08:21:47.807946	\N	completed	3
27550	7	450.00	6	2025-07-01 19:36:47.807946	2025-07-01 20:09:47.807946	\N	completed	32
27551	11	450.00	9	2025-07-01 14:07:47.807946	2025-07-01 14:46:47.807946	\N	completed	11
27552	15	440.00	4	2025-07-01 05:08:47.807946	2025-07-01 05:49:47.807946	\N	completed	32
27553	14	510.00	6	2025-07-01 13:26:47.807946	2025-07-01 13:55:47.807946	\N	completed	11
27554	2	510.00	6	2025-07-01 13:01:47.807946	2025-07-01 13:44:47.807946	\N	completed	36
27555	14	850.00	4	2025-07-01 07:45:47.807946	2025-07-01 08:30:47.807946	\N	completed	11
27556	28	500.00	5	2025-07-01 20:14:47.807946	2025-07-01 20:50:47.807946	\N	completed	34
27557	8	400.00	4	2025-07-01 20:47:47.807946	2025-07-01 21:14:47.807946	\N	completed	3
27558	30	575.00	4	2025-07-01 18:07:47.807946	2025-07-01 18:35:47.807946	\N	completed	8
27559	12	480.00	7	2025-07-01 05:09:47.807946	2025-07-01 05:37:47.807946	\N	completed	9
27560	9	575.00	4	2025-07-01 16:49:47.807946	2025-07-01 17:31:47.807946	\N	completed	9
27561	16	520.00	6	2025-07-01 22:50:47.807946	2025-07-01 23:25:47.807946	\N	completed	10
27562	7	330.00	5	2025-07-01 14:34:47.807946	2025-07-01 15:14:47.807946	\N	completed	3
27563	28	525.00	4	2025-07-01 11:54:47.807946	2025-07-01 12:15:47.807946	\N	completed	36
27564	9	340.00	4	2025-07-01 22:46:47.807946	2025-07-01 23:32:47.807946	\N	completed	36
27565	30	560.00	4	2025-07-01 20:46:47.807946	2025-07-01 21:13:47.807946	\N	completed	36
27566	8	675.00	7	2025-07-01 17:43:47.807946	2025-07-01 18:15:47.807946	\N	completed	36
27567	12	300.00	6	2025-07-01 22:36:47.807946	2025-07-01 23:19:47.807946	\N	completed	3
27568	9	465.00	7	2025-07-01 10:27:47.807946	2025-07-01 11:07:47.807946	\N	completed	32
27569	9	300.00	5	2025-07-01 21:58:47.807946	2025-07-01 22:35:47.807946	\N	completed	8
27570	2	675.00	6	2025-07-01 08:02:47.807946	2025-07-01 08:25:47.807946	\N	completed	9
27571	9	360.00	9	2025-07-02 14:37:47.807946	2025-07-02 15:00:47.807946	\N	completed	6
27572	12	360.00	6	2025-07-02 12:44:47.807946	2025-07-02 13:29:47.807946	\N	completed	11
27573	28	825.00	6	2025-07-02 18:05:47.807946	2025-07-02 18:34:47.807946	\N	completed	3
27574	7	360.00	9	2025-07-02 14:40:47.807946	2025-07-02 15:23:47.807946	\N	completed	6
27575	7	345.00	6	2025-07-02 13:02:47.807946	2025-07-02 13:44:47.807946	\N	completed	10
27576	16	260.00	5	2025-07-02 06:34:47.807946	2025-07-02 07:01:47.807946	\N	completed	10
27577	2	975.00	9	2025-07-02 16:17:47.807946	2025-07-02 16:43:47.807946	\N	completed	1
27578	15	510.00	5	2025-07-02 09:40:47.807946	2025-07-02 10:12:47.807946	\N	completed	9
27579	12	320.00	4	2025-07-02 20:44:47.807946	2025-07-02 21:04:47.807946	\N	completed	8
27580	28	360.00	7	2025-07-02 12:40:47.807946	2025-07-02 13:16:47.807946	\N	completed	36
27581	11	420.00	8	2025-07-02 22:17:47.807946	2025-07-02 22:39:47.807946	\N	completed	11
27582	11	460.00	6	2025-07-02 05:19:47.807946	2025-07-02 06:03:47.807946	\N	completed	6
27583	10	560.00	8	2025-07-02 20:15:47.807946	2025-07-02 20:49:47.807946	\N	completed	34
27584	30	375.00	7	2025-07-02 14:11:47.807946	2025-07-02 14:40:47.807946	\N	completed	8
27585	28	345.00	8	2025-07-02 12:45:47.807946	2025-07-02 13:26:47.807946	\N	completed	10
27586	7	950.00	4	2025-07-02 16:53:47.807946	2025-07-02 17:31:47.807946	\N	completed	32
27587	9	360.00	4	2025-07-02 13:34:47.807946	2025-07-02 14:17:47.807946	\N	completed	1
27588	8	400.00	7	2025-07-03 21:33:47.807946	2025-07-03 22:10:47.807946	\N	completed	36
27589	11	465.00	8	2025-07-03 15:22:47.807946	2025-07-03 16:06:47.807946	\N	completed	6
27590	7	825.00	7	2025-07-03 17:38:47.807946	2025-07-03 18:01:47.807946	\N	completed	3
27591	9	435.00	9	2025-07-03 19:16:47.807946	2025-07-03 20:04:47.807946	\N	completed	34
27592	9	725.00	5	2025-07-03 07:56:47.807946	2025-07-03 08:46:47.807946	\N	completed	9
27593	7	725.00	9	2025-07-03 17:56:47.807946	2025-07-03 18:32:47.807946	\N	completed	1
27594	8	480.00	9	2025-07-03 21:49:47.807946	2025-07-03 22:15:47.807946	\N	completed	6
27595	7	460.00	8	2025-07-03 21:12:47.807946	2025-07-03 21:32:47.807946	\N	completed	8
27596	11	405.00	6	2025-07-03 12:22:47.807946	2025-07-03 13:10:47.807946	\N	completed	1
27597	30	540.00	6	2025-07-03 20:36:47.807946	2025-07-03 21:02:47.807946	\N	completed	10
27598	28	550.00	5	2025-07-03 08:08:47.807946	2025-07-03 08:33:47.807946	\N	completed	6
27599	11	330.00	4	2025-07-03 15:32:47.807946	2025-07-03 15:59:47.807946	\N	completed	36
27600	8	360.00	8	2025-07-03 12:29:47.807946	2025-07-03 13:16:47.807946	\N	completed	1
27601	7	315.00	5	2025-07-03 09:19:47.807946	2025-07-03 09:40:47.807946	\N	completed	36
27602	12	495.00	4	2025-07-03 09:14:47.807946	2025-07-03 09:42:47.807946	\N	completed	11
27603	14	435.00	4	2025-07-03 09:09:47.807946	2025-07-03 09:30:47.807946	\N	completed	36
27604	8	435.00	8	2025-07-03 09:26:47.807946	2025-07-03 10:10:47.807946	\N	completed	6
27605	28	510.00	8	2025-07-03 10:06:47.807946	2025-07-03 10:35:47.807946	\N	completed	1
27606	8	360.00	8	2025-07-03 09:13:47.807946	2025-07-03 09:37:47.807946	\N	completed	11
27607	9	550.00	7	2025-07-03 18:19:47.807946	2025-07-03 18:51:47.807946	\N	completed	11
27608	28	525.00	4	2025-07-03 15:49:47.807946	2025-07-03 16:23:47.807946	\N	completed	11
27609	16	400.00	9	2025-07-03 22:44:47.807946	2025-07-03 23:20:47.807946	\N	completed	3
27610	12	465.00	5	2025-07-03 12:10:47.807946	2025-07-03 12:54:47.807946	\N	completed	11
27611	30	825.00	4	2025-07-03 17:18:47.807946	2025-07-03 17:44:47.807946	\N	completed	10
27612	14	480.00	4	2025-07-04 05:43:47.807946	2025-07-04 06:17:47.807946	\N	completed	6
27613	11	270.00	9	2025-07-04 19:54:47.807946	2025-07-04 20:41:47.807946	\N	completed	8
27614	28	750.00	7	2025-07-04 17:51:47.807946	2025-07-04 18:24:47.807946	\N	completed	1
27615	14	1000.00	5	2025-07-04 17:22:47.807946	2025-07-04 18:10:47.807946	\N	completed	34
27616	14	420.00	7	2025-07-04 11:20:47.807946	2025-07-04 12:10:47.807946	\N	completed	32
27617	14	420.00	6	2025-07-04 09:19:47.807946	2025-07-04 10:08:47.807946	\N	completed	1
27618	8	285.00	5	2025-07-04 09:41:47.807946	2025-07-04 10:03:47.807946	\N	completed	9
27619	16	480.00	8	2025-07-04 06:24:47.807946	2025-07-04 06:51:47.807946	\N	completed	11
27620	11	625.00	9	2025-07-04 18:59:47.807946	2025-07-04 19:34:47.807946	\N	completed	1
27621	7	460.00	8	2025-07-04 06:41:47.807946	2025-07-04 07:31:47.807946	\N	completed	6
27622	8	345.00	7	2025-07-04 15:34:47.807946	2025-07-04 16:21:47.807946	\N	completed	34
27623	2	390.00	6	2025-07-04 15:32:47.807946	2025-07-04 16:19:47.807946	\N	completed	32
27624	14	625.00	4	2025-07-04 17:19:47.807946	2025-07-04 17:41:47.807946	\N	completed	32
27625	2	450.00	4	2025-07-04 09:39:47.807946	2025-07-04 10:24:47.807946	\N	completed	11
27626	2	510.00	5	2025-07-04 15:03:47.807946	2025-07-04 15:44:47.807946	\N	completed	3
27627	11	825.00	7	2025-07-04 07:02:47.807946	2025-07-04 07:27:47.807946	\N	completed	10
27628	11	285.00	7	2025-07-04 15:48:47.807946	2025-07-04 16:11:47.807946	\N	completed	1
27629	10	550.00	4	2025-07-04 18:01:47.807946	2025-07-04 18:45:47.807946	\N	completed	10
27630	12	495.00	5	2025-07-04 12:52:47.807946	2025-07-04 13:21:47.807946	\N	completed	3
27631	12	850.00	7	2025-07-04 17:24:47.807946	2025-07-04 18:10:47.807946	\N	completed	1
27632	14	345.00	7	2025-07-04 09:57:47.807946	2025-07-04 10:47:47.807946	\N	completed	3
27633	14	500.00	6	2025-07-04 21:55:47.807946	2025-07-04 22:24:47.807946	\N	completed	11
27634	16	525.00	7	2025-07-04 11:50:47.807946	2025-07-04 12:31:47.807946	\N	completed	1
27635	9	405.00	9	2025-07-04 14:33:47.807946	2025-07-04 15:10:47.807946	\N	completed	32
27636	16	495.00	4	2025-07-05 09:15:47.807946	2025-07-05 09:46:47.807946	\N	completed	1
27637	16	440.00	9	2025-07-05 22:54:47.807946	2025-07-05 23:43:47.807946	\N	completed	11
27638	9	315.00	5	2025-07-05 19:11:47.807946	2025-07-05 19:58:47.807946	\N	completed	34
27639	15	650.00	6	2025-07-05 07:19:47.807946	2025-07-05 07:58:47.807946	\N	completed	8
27640	9	510.00	5	2025-07-05 12:38:47.807946	2025-07-05 13:13:47.807946	\N	completed	6
27641	15	625.00	4	2025-07-05 17:38:47.807946	2025-07-05 18:08:47.807946	\N	completed	1
27642	30	380.00	8	2025-07-05 05:50:47.807946	2025-07-05 06:26:47.807946	\N	completed	6
27643	28	440.00	5	2025-07-05 05:25:47.807946	2025-07-05 05:59:47.807946	\N	completed	1
27644	28	875.00	7	2025-07-05 08:00:47.807946	2025-07-05 08:48:47.807946	\N	completed	36
27645	7	600.00	5	2025-07-05 17:10:47.807946	2025-07-05 17:40:47.807946	\N	completed	36
27646	7	315.00	5	2025-07-05 15:35:47.807946	2025-07-05 16:01:47.807946	\N	completed	34
27647	2	315.00	7	2025-07-05 13:02:47.807946	2025-07-05 13:43:47.807946	\N	completed	3
27648	7	500.00	6	2025-07-05 06:13:47.807946	2025-07-05 06:44:47.807946	\N	completed	34
27649	11	625.00	9	2025-07-05 18:46:47.807946	2025-07-05 19:26:47.807946	\N	completed	11
27650	8	380.00	9	2025-07-05 21:03:47.807946	2025-07-05 21:40:47.807946	\N	completed	6
27651	12	510.00	9	2025-07-05 14:49:47.807946	2025-07-05 15:18:47.807946	\N	completed	1
27652	9	465.00	8	2025-07-05 12:14:47.807946	2025-07-05 13:02:47.807946	\N	completed	1
27653	30	340.00	6	2025-07-05 20:31:47.807946	2025-07-05 21:03:47.807946	\N	completed	32
27654	12	300.00	6	2025-07-05 09:12:47.807946	2025-07-05 10:02:47.807946	\N	completed	32
27655	11	420.00	5	2025-07-05 22:23:47.807946	2025-07-05 22:51:47.807946	\N	completed	3
27656	16	875.00	4	2025-07-05 08:29:47.807946	2025-07-05 08:49:47.807946	\N	completed	11
27657	7	700.00	9	2025-07-05 16:42:47.807946	2025-07-05 17:17:47.807946	\N	completed	11
27658	15	800.00	6	2025-07-05 16:46:47.807946	2025-07-05 17:26:47.807946	\N	completed	11
27659	28	420.00	5	2025-07-05 05:55:47.807946	2025-07-05 06:45:47.807946	\N	completed	9
27660	28	950.00	4	2025-07-05 18:46:47.807946	2025-07-05 19:28:47.807946	\N	completed	32
27661	7	300.00	4	2025-07-06 20:22:47.807946	2025-07-06 21:11:47.807946	\N	completed	11
27662	14	405.00	6	2025-07-06 13:29:47.807946	2025-07-06 13:56:47.807946	\N	completed	3
27663	10	850.00	4	2025-07-06 07:43:47.807946	2025-07-06 08:08:47.807946	\N	completed	36
27664	2	270.00	8	2025-07-06 12:32:47.807946	2025-07-06 13:22:47.807946	\N	completed	36
27665	16	775.00	9	2025-07-06 18:48:47.807946	2025-07-06 19:24:47.807946	\N	completed	8
27666	28	510.00	4	2025-07-06 11:18:47.807946	2025-07-06 11:42:47.807946	\N	completed	6
27667	12	405.00	5	2025-07-06 15:49:47.807946	2025-07-06 16:23:47.807946	\N	completed	9
27668	11	360.00	6	2025-07-06 12:58:47.807946	2025-07-06 13:25:47.807946	\N	completed	10
27669	12	300.00	4	2025-07-06 13:42:47.807946	2025-07-06 14:05:47.807946	\N	completed	34
27670	15	360.00	4	2025-07-06 21:17:47.807946	2025-07-06 22:02:47.807946	\N	completed	1
27671	7	625.00	8	2025-07-06 18:38:47.807946	2025-07-06 19:20:47.807946	\N	completed	34
27672	30	435.00	6	2025-07-06 09:02:47.807946	2025-07-06 09:38:47.807946	\N	completed	10
27673	28	300.00	5	2025-07-06 14:34:47.807946	2025-07-06 15:02:47.807946	\N	completed	32
27674	10	420.00	8	2025-07-06 14:18:47.807946	2025-07-06 15:05:47.807946	\N	completed	10
27675	15	525.00	8	2025-07-06 12:08:47.807946	2025-07-06 12:52:47.807946	\N	completed	8
27676	28	1025.00	6	2025-07-06 17:27:47.807946	2025-07-06 18:17:47.807946	\N	completed	10
27677	28	440.00	7	2025-07-06 06:59:47.807946	2025-07-06 07:21:47.807946	\N	completed	3
27678	10	550.00	5	2025-07-06 16:46:47.807946	2025-07-06 17:31:47.807946	\N	completed	3
27679	11	390.00	9	2025-07-06 14:46:47.807946	2025-07-06 15:20:47.807946	\N	completed	8
27680	30	280.00	8	2025-07-06 05:41:47.807946	2025-07-06 06:13:47.807946	\N	completed	34
27681	2	800.00	9	2025-07-06 17:24:47.807946	2025-07-06 18:10:47.807946	\N	completed	11
27682	12	480.00	6	2025-07-06 12:16:47.807946	2025-07-06 12:43:47.807946	\N	completed	1
27683	14	420.00	9	2025-07-06 22:59:47.807946	2025-07-06 23:36:47.807946	\N	completed	32
27684	9	420.00	7	2025-07-06 21:11:47.807946	2025-07-06 21:39:47.807946	\N	completed	3
27685	14	495.00	6	2025-07-06 11:55:47.807946	2025-07-06 12:40:47.807946	\N	completed	9
27686	14	320.00	6	2025-07-06 21:42:47.807946	2025-07-06 22:21:47.807946	\N	completed	34
27687	30	450.00	6	2025-07-06 15:53:47.807946	2025-07-06 16:25:47.807946	\N	completed	36
27688	15	550.00	5	2025-07-06 08:07:47.807946	2025-07-06 08:45:47.807946	\N	completed	10
27689	8	510.00	7	2025-07-06 15:32:47.807946	2025-07-06 16:05:47.807946	\N	completed	36
27690	16	435.00	8	2025-07-06 09:20:47.807946	2025-07-06 10:04:47.807946	\N	completed	1
27691	9	450.00	6	2025-07-06 09:01:47.807946	2025-07-06 09:46:47.807946	\N	completed	34
27692	14	400.00	6	2025-07-07 05:15:47.807946	2025-07-07 05:42:47.807946	\N	completed	11
27693	30	330.00	4	2025-07-07 10:14:47.807946	2025-07-07 10:42:47.807946	\N	completed	11
27694	16	270.00	7	2025-07-07 11:46:47.807946	2025-07-07 12:26:47.807946	\N	completed	6
27695	15	375.00	6	2025-07-07 09:49:47.807946	2025-07-07 10:30:47.807946	\N	completed	8
27696	10	345.00	5	2025-07-07 15:38:47.807946	2025-07-07 15:58:47.807946	\N	completed	11
27697	16	465.00	9	2025-07-07 15:46:47.807946	2025-07-07 16:35:47.807946	\N	completed	8
27698	30	330.00	8	2025-07-07 12:13:47.807946	2025-07-07 12:43:47.807946	\N	completed	3
27699	10	300.00	6	2025-07-07 20:59:47.807946	2025-07-07 21:40:47.807946	\N	completed	6
27700	28	575.00	4	2025-07-07 08:06:47.807946	2025-07-07 08:44:47.807946	\N	completed	36
27701	10	340.00	4	2025-07-07 22:52:47.807946	2025-07-07 23:24:47.807946	\N	completed	8
27702	15	360.00	4	2025-07-07 19:14:47.807946	2025-07-07 19:42:47.807946	\N	completed	10
27703	12	900.00	5	2025-07-07 18:22:47.807946	2025-07-07 18:55:47.807946	\N	completed	6
27704	28	375.00	9	2025-07-07 13:36:47.807946	2025-07-07 14:21:47.807946	\N	completed	1
27705	8	480.00	7	2025-07-07 06:04:47.807946	2025-07-07 06:25:47.807946	\N	completed	1
27706	30	375.00	7	2025-07-07 12:21:47.807946	2025-07-07 13:06:47.807946	\N	completed	32
27707	15	510.00	4	2025-07-07 12:08:47.807946	2025-07-07 12:53:47.807946	\N	completed	32
27708	8	1025.00	8	2025-07-07 07:02:47.807946	2025-07-07 07:25:47.807946	\N	completed	11
27709	28	600.00	8	2025-07-07 08:04:47.807946	2025-07-07 08:33:47.807946	\N	completed	34
27710	15	285.00	4	2025-07-07 14:02:47.807946	2025-07-07 14:52:47.807946	\N	completed	34
27711	11	525.00	8	2025-07-07 07:05:47.807946	2025-07-07 07:46:47.807946	\N	completed	3
27712	12	405.00	6	2025-07-07 13:30:47.807946	2025-07-07 14:09:47.807946	\N	completed	32
27713	14	850.00	9	2025-07-08 16:52:47.807946	2025-07-08 17:25:47.807946	\N	completed	6
27714	9	450.00	4	2025-07-08 14:47:47.807946	2025-07-08 15:19:47.807946	\N	completed	6
27715	14	875.00	9	2025-07-08 16:14:47.807946	2025-07-08 16:35:47.807946	\N	completed	6
27716	9	1000.00	9	2025-07-08 17:10:47.807946	2025-07-08 17:35:47.807946	\N	completed	34
27717	30	440.00	8	2025-07-08 22:38:47.807946	2025-07-08 23:07:47.807946	\N	completed	3
27718	14	480.00	6	2025-07-08 09:58:47.807946	2025-07-08 10:27:47.807946	\N	completed	6
27719	12	700.00	9	2025-07-08 17:15:47.807946	2025-07-08 17:43:47.807946	\N	completed	1
27720	28	500.00	6	2025-07-08 05:31:47.807946	2025-07-08 06:14:47.807946	\N	completed	36
27721	2	825.00	9	2025-07-08 08:19:47.807946	2025-07-08 08:39:47.807946	\N	completed	8
27722	9	405.00	5	2025-07-08 13:23:47.807946	2025-07-08 13:55:47.807946	\N	completed	1
27723	16	300.00	9	2025-07-08 05:14:47.807946	2025-07-08 05:38:47.807946	\N	completed	8
27724	7	480.00	6	2025-07-08 13:44:47.807946	2025-07-08 14:10:47.807946	\N	completed	9
27725	28	900.00	5	2025-07-08 17:16:47.807946	2025-07-08 17:49:47.807946	\N	completed	6
27726	2	320.00	6	2025-07-08 21:57:47.807946	2025-07-08 22:23:47.807946	\N	completed	9
27727	30	260.00	7	2025-07-08 05:28:47.807946	2025-07-08 05:55:47.807946	\N	completed	10
27728	28	375.00	9	2025-07-08 15:57:47.807946	2025-07-08 16:24:47.807946	\N	completed	11
27729	2	520.00	9	2025-07-08 22:41:47.807946	2025-07-08 23:01:47.807946	\N	completed	34
27730	15	405.00	5	2025-07-08 15:55:47.807946	2025-07-08 16:33:47.807946	\N	completed	36
27731	7	300.00	6	2025-07-08 12:45:47.807946	2025-07-08 13:28:47.807946	\N	completed	3
27732	8	450.00	5	2025-07-08 14:37:47.807946	2025-07-08 15:04:47.807946	\N	completed	11
27733	7	500.00	7	2025-07-08 22:19:47.807946	2025-07-08 22:41:47.807946	\N	completed	11
27734	7	380.00	6	2025-07-08 22:00:47.807946	2025-07-08 22:41:47.807946	\N	completed	34
27735	2	975.00	5	2025-07-08 07:40:47.807946	2025-07-08 08:05:47.807946	\N	completed	32
27736	30	315.00	4	2025-07-08 10:25:47.807946	2025-07-08 10:47:47.807946	\N	completed	6
27737	15	850.00	6	2025-07-08 08:10:47.807946	2025-07-08 08:31:47.807946	\N	completed	11
27738	11	675.00	8	2025-07-08 18:02:47.807946	2025-07-08 18:49:47.807946	\N	completed	36
27739	2	540.00	4	2025-07-08 21:39:47.807946	2025-07-08 22:25:47.807946	\N	completed	34
27740	15	480.00	8	2025-07-09 09:07:47.807946	2025-07-09 09:46:47.807946	\N	completed	6
27741	10	465.00	5	2025-07-09 11:00:47.807946	2025-07-09 11:29:47.807946	\N	completed	3
27742	16	650.00	9	2025-07-09 07:19:47.807946	2025-07-09 07:46:47.807946	\N	completed	11
27743	7	465.00	9	2025-07-09 10:33:47.807946	2025-07-09 11:15:47.807946	\N	completed	11
27744	10	375.00	7	2025-07-09 15:25:47.807946	2025-07-09 15:48:47.807946	\N	completed	1
27745	16	330.00	8	2025-07-09 11:17:47.807946	2025-07-09 11:37:47.807946	\N	completed	3
27746	30	495.00	8	2025-07-09 13:29:47.807946	2025-07-09 14:19:47.807946	\N	completed	36
27747	14	360.00	4	2025-07-09 06:17:47.807946	2025-07-09 06:42:47.807946	\N	completed	1
27748	8	580.00	9	2025-07-09 22:50:47.807946	2025-07-09 23:13:47.807946	\N	completed	6
27749	15	300.00	6	2025-07-09 21:54:47.807946	2025-07-09 22:40:47.807946	\N	completed	3
27750	8	800.00	4	2025-07-09 08:02:47.807946	2025-07-09 08:52:47.807946	\N	completed	10
27751	7	320.00	6	2025-07-09 05:25:47.807946	2025-07-09 06:02:47.807946	\N	completed	3
27752	10	600.00	6	2025-07-09 18:19:47.807946	2025-07-09 18:42:47.807946	\N	completed	36
27753	28	435.00	6	2025-07-09 13:13:47.807946	2025-07-09 13:33:47.807946	\N	completed	1
27754	12	405.00	6	2025-07-09 13:23:47.807946	2025-07-09 14:07:47.807946	\N	completed	10
27755	14	510.00	7	2025-07-09 13:50:47.807946	2025-07-09 14:27:47.807946	\N	completed	36
27756	16	390.00	5	2025-07-09 10:43:47.807946	2025-07-09 11:15:47.807946	\N	completed	1
27757	7	625.00	4	2025-07-09 08:23:47.807946	2025-07-09 08:55:47.807946	\N	completed	11
27758	14	270.00	9	2025-07-09 13:33:47.807946	2025-07-09 13:59:47.807946	\N	completed	10
27759	10	480.00	4	2025-07-09 12:00:47.807946	2025-07-09 12:45:47.807946	\N	completed	10
27760	10	700.00	8	2025-07-10 08:03:47.807946	2025-07-10 08:44:47.807946	\N	completed	10
27761	30	405.00	5	2025-07-10 11:42:47.807946	2025-07-10 12:11:47.807946	\N	completed	32
27762	15	495.00	4	2025-07-10 12:13:47.807946	2025-07-10 12:56:47.807946	\N	completed	3
27763	14	450.00	7	2025-07-10 15:26:47.807946	2025-07-10 16:00:47.807946	\N	completed	32
27764	8	270.00	6	2025-07-10 13:29:47.807946	2025-07-10 13:59:47.807946	\N	completed	36
27765	12	465.00	5	2025-07-10 11:47:47.807946	2025-07-10 12:25:47.807946	\N	completed	8
27766	12	510.00	4	2025-07-10 14:41:47.807946	2025-07-10 15:19:47.807946	\N	completed	8
27767	16	375.00	9	2025-07-10 11:27:47.807946	2025-07-10 11:53:47.807946	\N	completed	6
27768	30	420.00	8	2025-07-10 06:56:47.807946	2025-07-10 07:35:47.807946	\N	completed	8
27769	8	850.00	4	2025-07-10 07:01:47.807946	2025-07-10 07:23:47.807946	\N	completed	32
27770	30	340.00	5	2025-07-10 20:36:47.807946	2025-07-10 21:09:47.807946	\N	completed	9
27771	30	330.00	9	2025-07-10 11:02:47.807946	2025-07-10 11:39:47.807946	\N	completed	10
27772	28	465.00	9	2025-07-10 11:08:47.807946	2025-07-10 11:50:47.807946	\N	completed	36
27773	30	435.00	6	2025-07-10 10:22:47.807946	2025-07-10 10:44:47.807946	\N	completed	36
27774	7	800.00	7	2025-07-10 08:59:47.807946	2025-07-10 09:24:47.807946	\N	completed	36
27775	16	315.00	4	2025-07-10 19:15:47.807946	2025-07-10 19:41:47.807946	\N	completed	8
27776	9	495.00	8	2025-07-10 11:52:47.807946	2025-07-10 12:34:47.807946	\N	completed	6
27777	11	320.00	8	2025-07-10 20:21:47.807946	2025-07-10 20:47:47.807946	\N	completed	34
27778	7	280.00	4	2025-07-10 05:39:47.807946	2025-07-10 06:22:47.807946	\N	completed	36
27779	2	345.00	6	2025-07-10 11:43:47.807946	2025-07-10 12:15:47.807946	\N	completed	34
27780	10	575.00	7	2025-07-10 18:22:47.807946	2025-07-10 18:58:47.807946	\N	completed	34
27781	7	925.00	7	2025-07-10 16:54:47.807946	2025-07-10 17:18:47.807946	\N	completed	10
27782	7	460.00	8	2025-07-10 22:30:47.807946	2025-07-10 23:18:47.807946	\N	completed	36
27783	11	650.00	4	2025-07-11 16:51:47.807946	2025-07-11 17:24:47.807946	\N	completed	36
27784	14	575.00	4	2025-07-11 16:18:47.807946	2025-07-11 16:49:47.807946	\N	completed	8
27785	30	420.00	5	2025-07-11 13:40:47.807946	2025-07-11 14:14:47.807946	\N	completed	34
27786	2	380.00	5	2025-07-11 20:33:47.807946	2025-07-11 21:12:47.807946	\N	completed	1
27787	2	405.00	5	2025-07-11 19:40:47.807946	2025-07-11 20:07:47.807946	\N	completed	8
27788	28	270.00	6	2025-07-11 13:17:47.807946	2025-07-11 13:41:47.807946	\N	completed	6
27789	2	775.00	8	2025-07-11 16:17:47.807946	2025-07-11 16:51:47.807946	\N	completed	6
27790	30	450.00	9	2025-07-11 15:08:47.807946	2025-07-11 15:39:47.807946	\N	completed	3
27791	10	925.00	8	2025-07-11 08:04:47.807946	2025-07-11 08:40:47.807946	\N	completed	3
27792	28	405.00	4	2025-07-11 15:27:47.807946	2025-07-11 15:55:47.807946	\N	completed	36
27793	28	450.00	7	2025-07-11 14:05:47.807946	2025-07-11 14:35:47.807946	\N	completed	32
27794	9	360.00	7	2025-07-11 06:32:47.807946	2025-07-11 07:16:47.807946	\N	completed	9
27795	14	850.00	5	2025-07-11 08:56:47.807946	2025-07-11 09:44:47.807946	\N	completed	9
27796	8	440.00	5	2025-07-11 06:57:47.807946	2025-07-11 07:41:47.807946	\N	completed	1
27797	28	380.00	8	2025-07-11 22:38:47.807946	2025-07-11 23:05:47.807946	\N	completed	1
27798	16	480.00	7	2025-07-11 14:02:47.807946	2025-07-11 14:52:47.807946	\N	completed	9
27799	7	435.00	8	2025-07-11 19:30:47.807946	2025-07-11 19:59:47.807946	\N	completed	1
27800	11	285.00	5	2025-07-11 12:11:47.807946	2025-07-11 12:47:47.807946	\N	completed	9
27801	30	510.00	6	2025-07-11 09:35:47.807946	2025-07-11 10:14:47.807946	\N	completed	6
27802	9	800.00	5	2025-07-11 16:35:47.807946	2025-07-11 17:22:47.807946	\N	completed	9
27803	15	750.00	6	2025-07-11 16:20:47.807946	2025-07-11 16:50:47.807946	\N	completed	6
27804	2	465.00	7	2025-07-11 14:00:47.807946	2025-07-11 14:38:47.807946	\N	completed	10
27805	30	360.00	8	2025-07-11 12:02:47.807946	2025-07-11 12:40:47.807946	\N	completed	6
27806	9	525.00	5	2025-07-11 11:37:47.807946	2025-07-11 12:08:47.807946	\N	completed	11
27807	28	725.00	6	2025-07-12 08:26:47.807946	2025-07-12 09:16:47.807946	\N	completed	10
27808	12	800.00	5	2025-07-12 18:26:47.807946	2025-07-12 18:56:47.807946	\N	completed	1
27809	8	380.00	9	2025-07-12 05:20:47.807946	2025-07-12 05:55:47.807946	\N	completed	3
27810	16	380.00	9	2025-07-12 20:05:47.807946	2025-07-12 20:47:47.807946	\N	completed	6
27811	12	600.00	5	2025-07-12 20:53:47.807946	2025-07-12 21:39:47.807946	\N	completed	32
27812	30	315.00	5	2025-07-12 15:08:47.807946	2025-07-12 15:41:47.807946	\N	completed	9
27813	28	875.00	5	2025-07-12 16:46:47.807946	2025-07-12 17:28:47.807946	\N	completed	8
27814	2	465.00	6	2025-07-12 14:08:47.807946	2025-07-12 14:42:47.807946	\N	completed	1
27815	10	405.00	8	2025-07-12 12:03:47.807946	2025-07-12 12:30:47.807946	\N	completed	10
27816	7	675.00	5	2025-07-12 07:48:47.807946	2025-07-12 08:38:47.807946	\N	completed	34
27817	8	1025.00	6	2025-07-12 18:46:47.807946	2025-07-12 19:13:47.807946	\N	completed	3
27818	8	510.00	9	2025-07-12 13:27:47.807946	2025-07-12 14:07:47.807946	\N	completed	1
27819	30	900.00	4	2025-07-12 07:37:47.807946	2025-07-12 08:15:47.807946	\N	completed	9
27820	16	280.00	8	2025-07-12 05:39:47.807946	2025-07-12 06:11:47.807946	\N	completed	32
27821	11	1000.00	6	2025-07-12 16:48:47.807946	2025-07-12 17:10:47.807946	\N	completed	11
27822	9	560.00	9	2025-07-12 22:06:47.807946	2025-07-12 22:30:47.807946	\N	completed	36
27823	10	875.00	4	2025-07-12 08:45:47.807946	2025-07-12 09:17:47.807946	\N	completed	1
27824	10	700.00	9	2025-07-12 18:42:47.807946	2025-07-12 19:20:47.807946	\N	completed	8
27825	14	950.00	8	2025-07-12 18:27:47.807946	2025-07-12 18:57:47.807946	\N	completed	32
27826	14	480.00	5	2025-07-12 10:19:47.807946	2025-07-12 11:05:47.807946	\N	completed	11
27827	10	775.00	9	2025-07-12 16:31:47.807946	2025-07-12 17:21:47.807946	\N	completed	6
27828	10	360.00	9	2025-07-12 20:38:47.807946	2025-07-12 21:11:47.807946	\N	completed	1
27829	10	875.00	4	2025-07-13 08:40:47.807946	2025-07-13 09:22:47.807946	\N	completed	11
27830	9	460.00	8	2025-07-13 05:21:47.807946	2025-07-13 05:57:47.807946	\N	completed	36
27831	14	750.00	8	2025-07-13 08:02:47.807946	2025-07-13 08:47:47.807946	\N	completed	36
27832	2	480.00	8	2025-07-13 13:33:47.807946	2025-07-13 13:54:47.807946	\N	completed	9
27833	15	280.00	9	2025-07-13 05:03:47.807946	2025-07-13 05:51:47.807946	\N	completed	36
27834	14	525.00	9	2025-07-13 13:36:47.807946	2025-07-13 14:08:47.807946	\N	completed	3
27835	10	280.00	4	2025-07-13 05:54:47.807946	2025-07-13 06:17:47.807946	\N	completed	34
27836	28	420.00	7	2025-07-13 10:31:47.807946	2025-07-13 10:53:47.807946	\N	completed	34
27837	15	750.00	9	2025-07-13 08:43:47.807946	2025-07-13 09:04:47.807946	\N	completed	1
27838	8	480.00	9	2025-07-13 20:10:47.807946	2025-07-13 20:48:47.807946	\N	completed	8
27839	2	435.00	5	2025-07-13 13:24:47.807946	2025-07-13 13:52:47.807946	\N	completed	36
27840	7	550.00	5	2025-07-13 07:58:47.807946	2025-07-13 08:29:47.807946	\N	completed	1
27841	8	420.00	7	2025-07-13 12:47:47.807946	2025-07-13 13:27:47.807946	\N	completed	34
27842	8	600.00	4	2025-07-13 20:16:47.807946	2025-07-13 20:36:47.807946	\N	completed	3
27843	16	315.00	7	2025-07-13 19:35:47.807946	2025-07-13 20:07:47.807946	\N	completed	10
27844	14	510.00	9	2025-07-13 15:56:47.807946	2025-07-13 16:32:47.807946	\N	completed	3
27845	28	280.00	8	2025-07-13 05:51:47.807946	2025-07-13 06:12:47.807946	\N	completed	32
27846	7	900.00	7	2025-07-13 16:45:47.807946	2025-07-13 17:35:47.807946	\N	completed	1
27847	11	675.00	4	2025-07-13 16:12:47.807946	2025-07-13 17:02:47.807946	\N	completed	36
27848	10	575.00	8	2025-07-13 16:26:47.807946	2025-07-13 17:14:47.807946	\N	completed	6
27849	16	525.00	4	2025-07-13 09:45:47.807946	2025-07-13 10:23:47.807946	\N	completed	3
27850	28	480.00	4	2025-07-13 11:12:47.807946	2025-07-13 11:39:47.807946	\N	completed	10
27851	8	320.00	6	2025-07-13 21:28:47.807946	2025-07-13 21:51:47.807946	\N	completed	32
27852	8	360.00	9	2025-07-13 14:35:47.807946	2025-07-13 15:05:47.807946	\N	completed	11
27853	28	225.00	8	2025-07-14 19:25:47.807946	2025-07-14 20:02:47.807946	\N	completed	11
27854	10	420.00	9	2025-07-14 10:47:47.807946	2025-07-14 11:31:47.807946	\N	completed	1
27855	8	315.00	9	2025-07-14 19:58:47.807946	2025-07-14 20:23:47.807946	\N	completed	6
27856	9	435.00	7	2025-07-14 13:38:47.807946	2025-07-14 14:27:47.807946	\N	completed	32
27857	7	925.00	6	2025-07-14 07:58:47.807946	2025-07-14 08:29:47.807946	\N	completed	3
27858	8	700.00	8	2025-07-14 17:07:47.807946	2025-07-14 17:52:47.807946	\N	completed	1
27859	30	500.00	8	2025-07-14 06:12:47.807946	2025-07-14 06:45:47.807946	\N	completed	9
27860	8	450.00	9	2025-07-14 13:58:47.807946	2025-07-14 14:38:47.807946	\N	completed	3
27861	10	480.00	9	2025-07-14 20:06:47.807946	2025-07-14 20:48:47.807946	\N	completed	11
27862	30	510.00	9	2025-07-14 15:32:47.807946	2025-07-14 16:03:47.807946	\N	completed	3
27863	2	285.00	7	2025-07-14 09:29:47.807946	2025-07-14 10:07:47.807946	\N	completed	8
27864	2	450.00	4	2025-07-14 19:49:47.807946	2025-07-14 20:26:47.807946	\N	completed	11
27865	11	360.00	8	2025-07-14 14:45:47.807946	2025-07-14 15:32:47.807946	\N	completed	3
27866	30	875.00	5	2025-07-14 17:07:47.807946	2025-07-14 17:28:47.807946	\N	completed	3
27867	30	480.00	9	2025-07-14 11:17:47.807946	2025-07-14 11:59:47.807946	\N	completed	6
27868	8	270.00	6	2025-07-14 09:05:47.807946	2025-07-14 09:34:47.807946	\N	completed	6
27869	14	260.00	7	2025-07-14 05:22:47.807946	2025-07-14 05:59:47.807946	\N	completed	6
27870	7	540.00	6	2025-07-14 22:13:47.807946	2025-07-14 22:53:47.807946	\N	completed	8
27871	28	750.00	8	2025-07-14 07:33:47.807946	2025-07-14 08:23:47.807946	\N	completed	36
27872	7	345.00	5	2025-07-15 11:09:47.807946	2025-07-15 11:47:47.807946	\N	completed	1
27873	14	510.00	5	2025-07-15 09:39:47.807946	2025-07-15 10:29:47.807946	\N	completed	32
27874	11	510.00	4	2025-07-15 15:16:47.807946	2025-07-15 15:41:47.807946	\N	completed	1
27875	10	580.00	7	2025-07-15 20:50:47.807946	2025-07-15 21:37:47.807946	\N	completed	36
27876	28	225.00	9	2025-07-15 19:57:47.807946	2025-07-15 20:18:47.807946	\N	completed	10
27877	2	550.00	9	2025-07-15 08:12:47.807946	2025-07-15 09:01:47.807946	\N	completed	9
27878	7	510.00	9	2025-07-15 14:19:47.807946	2025-07-15 14:57:47.807946	\N	completed	3
27879	14	320.00	9	2025-07-15 06:09:47.807946	2025-07-15 06:45:47.807946	\N	completed	6
27880	12	675.00	7	2025-07-15 07:16:47.807946	2025-07-15 07:55:47.807946	\N	completed	1
27881	11	1000.00	9	2025-07-15 18:14:47.807946	2025-07-15 19:04:47.807946	\N	completed	11
27882	16	1000.00	5	2025-07-15 16:27:47.807946	2025-07-15 17:08:47.807946	\N	completed	8
27883	12	480.00	4	2025-07-15 15:18:47.807946	2025-07-15 15:44:47.807946	\N	completed	32
27884	8	225.00	6	2025-07-15 19:45:47.807946	2025-07-15 20:34:47.807946	\N	completed	9
27885	2	460.00	9	2025-07-15 21:42:47.807946	2025-07-15 22:14:47.807946	\N	completed	9
27886	28	450.00	8	2025-07-15 10:09:47.807946	2025-07-15 10:41:47.807946	\N	completed	32
27887	7	340.00	5	2025-07-15 20:52:47.807946	2025-07-15 21:33:47.807946	\N	completed	34
27888	9	320.00	4	2025-07-15 05:31:47.807946	2025-07-15 05:58:47.807946	\N	completed	11
27889	10	480.00	6	2025-07-15 13:58:47.807946	2025-07-15 14:32:47.807946	\N	completed	32
27890	30	270.00	8	2025-07-15 19:26:47.807946	2025-07-15 19:59:47.807946	\N	completed	8
27891	15	1025.00	9	2025-07-15 16:07:47.807946	2025-07-15 16:45:47.807946	\N	completed	36
27892	30	300.00	7	2025-07-16 06:07:47.807946	2025-07-16 06:49:47.807946	\N	completed	8
27893	15	525.00	8	2025-07-16 18:57:47.807946	2025-07-16 19:44:47.807946	\N	completed	9
27894	16	420.00	8	2025-07-16 22:30:47.807946	2025-07-16 23:12:47.807946	\N	completed	34
27895	10	850.00	9	2025-07-16 18:23:47.807946	2025-07-16 18:49:47.807946	\N	completed	10
27896	15	270.00	9	2025-07-16 14:17:47.807946	2025-07-16 14:48:47.807946	\N	completed	6
27897	28	900.00	7	2025-07-16 18:26:47.807946	2025-07-16 18:50:47.807946	\N	completed	9
27898	10	675.00	9	2025-07-16 07:58:47.807946	2025-07-16 08:24:47.807946	\N	completed	36
27899	28	900.00	8	2025-07-16 07:52:47.807946	2025-07-16 08:41:47.807946	\N	completed	1
27900	10	300.00	7	2025-07-16 10:56:47.807946	2025-07-16 11:36:47.807946	\N	completed	1
27901	12	465.00	6	2025-07-16 11:40:47.807946	2025-07-16 12:14:47.807946	\N	completed	10
27902	9	315.00	5	2025-07-16 10:11:47.807946	2025-07-16 10:55:47.807946	\N	completed	34
27903	10	540.00	8	2025-07-16 21:06:47.807946	2025-07-16 21:36:47.807946	\N	completed	3
27904	10	340.00	6	2025-07-16 06:06:47.807946	2025-07-16 06:55:47.807946	\N	completed	11
27905	15	390.00	5	2025-07-16 11:31:47.807946	2025-07-16 11:52:47.807946	\N	completed	11
27906	28	375.00	4	2025-07-16 12:32:47.807946	2025-07-16 13:01:47.807946	\N	completed	6
27907	15	375.00	8	2025-07-16 13:21:47.807946	2025-07-16 14:10:47.807946	\N	completed	3
27908	7	285.00	6	2025-07-16 19:41:47.807946	2025-07-16 20:17:47.807946	\N	completed	11
27909	10	315.00	9	2025-07-16 15:32:47.807946	2025-07-16 16:09:47.807946	\N	completed	8
27910	8	775.00	7	2025-07-16 07:16:47.807946	2025-07-16 07:55:47.807946	\N	completed	1
27911	10	300.00	8	2025-07-17 14:48:47.807946	2025-07-17 15:21:47.807946	\N	completed	10
27912	11	925.00	7	2025-07-17 18:21:47.807946	2025-07-17 19:04:47.807946	\N	completed	3
27913	12	480.00	7	2025-07-17 10:20:47.807946	2025-07-17 11:08:47.807946	\N	completed	34
27914	8	520.00	7	2025-07-17 21:12:47.807946	2025-07-17 21:49:47.807946	\N	completed	8
27915	16	360.00	9	2025-07-17 20:13:47.807946	2025-07-17 20:45:47.807946	\N	completed	6
27916	30	435.00	8	2025-07-17 15:23:47.807946	2025-07-17 15:53:47.807946	\N	completed	32
27917	8	510.00	6	2025-07-17 09:10:47.807946	2025-07-17 09:30:47.807946	\N	completed	11
27918	16	405.00	5	2025-07-17 11:42:47.807946	2025-07-17 12:03:47.807946	\N	completed	3
27919	14	420.00	6	2025-07-17 20:37:47.807946	2025-07-17 21:19:47.807946	\N	completed	8
27920	9	360.00	4	2025-07-17 06:35:47.807946	2025-07-17 06:56:47.807946	\N	completed	9
27921	14	650.00	5	2025-07-17 08:39:47.807946	2025-07-17 09:06:47.807946	\N	completed	36
27922	9	495.00	7	2025-07-17 12:08:47.807946	2025-07-17 12:28:47.807946	\N	completed	36
27923	2	400.00	6	2025-07-17 22:56:47.807946	2025-07-17 23:27:47.807946	\N	completed	3
27924	16	800.00	9	2025-07-17 18:37:47.807946	2025-07-17 19:09:47.807946	\N	completed	34
27925	8	480.00	7	2025-07-17 06:00:47.807946	2025-07-17 06:41:47.807946	\N	completed	1
27926	7	480.00	5	2025-07-17 06:19:47.807946	2025-07-17 06:51:47.807946	\N	completed	11
27927	16	825.00	4	2025-07-17 07:25:47.807946	2025-07-17 08:12:47.807946	\N	completed	36
27928	15	435.00	4	2025-07-17 12:14:47.807946	2025-07-17 12:47:47.807946	\N	completed	34
27929	28	330.00	4	2025-07-17 14:23:47.807946	2025-07-17 14:53:47.807946	\N	completed	10
27930	28	465.00	8	2025-07-17 14:11:47.807946	2025-07-17 14:57:47.807946	\N	completed	1
27931	28	950.00	5	2025-07-17 18:46:47.807946	2025-07-17 19:20:47.807946	\N	completed	9
27932	28	285.00	7	2025-07-18 19:01:47.807946	2025-07-18 19:41:47.807946	\N	completed	9
27933	30	725.00	8	2025-07-18 07:35:47.807946	2025-07-18 08:04:47.807946	\N	completed	36
27934	10	675.00	8	2025-07-18 18:09:47.807946	2025-07-18 18:30:47.807946	\N	completed	9
27935	11	300.00	6	2025-07-18 13:46:47.807946	2025-07-18 14:06:47.807946	\N	completed	10
27936	16	525.00	6	2025-07-18 12:17:47.807946	2025-07-18 12:43:47.807946	\N	completed	10
27937	10	285.00	7	2025-07-18 10:33:47.807946	2025-07-18 11:19:47.807946	\N	completed	11
27938	12	650.00	7	2025-07-18 17:53:47.807946	2025-07-18 18:42:47.807946	\N	completed	32
27939	16	460.00	7	2025-07-18 05:51:47.807946	2025-07-18 06:38:47.807946	\N	completed	3
27940	14	510.00	9	2025-07-18 14:54:47.807946	2025-07-18 15:29:47.807946	\N	completed	9
27941	28	700.00	8	2025-07-18 07:08:47.807946	2025-07-18 07:30:47.807946	\N	completed	1
27942	9	315.00	4	2025-07-18 11:47:47.807946	2025-07-18 12:16:47.807946	\N	completed	11
27943	8	480.00	8	2025-07-18 05:05:47.807946	2025-07-18 05:39:47.807946	\N	completed	36
27944	9	270.00	7	2025-07-18 14:34:47.807946	2025-07-18 15:03:47.807946	\N	completed	8
27945	11	950.00	8	2025-07-18 08:38:47.807946	2025-07-18 09:14:47.807946	\N	completed	6
27946	8	600.00	5	2025-07-18 22:11:47.807946	2025-07-18 22:41:47.807946	\N	completed	8
27947	15	390.00	5	2025-07-18 19:52:47.807946	2025-07-18 20:31:47.807946	\N	completed	1
27948	14	750.00	9	2025-07-18 16:39:47.807946	2025-07-18 17:04:47.807946	\N	completed	8
27949	12	500.00	7	2025-07-18 05:51:47.807946	2025-07-18 06:40:47.807946	\N	completed	34
27950	8	465.00	7	2025-07-18 11:58:47.807946	2025-07-18 12:34:47.807946	\N	completed	9
27951	28	525.00	5	2025-07-18 09:11:47.807946	2025-07-18 09:56:47.807946	\N	completed	10
27952	16	400.00	7	2025-07-18 05:00:47.807946	2025-07-18 05:37:47.807946	\N	completed	8
27953	14	300.00	6	2025-07-18 22:09:47.807946	2025-07-18 22:32:47.807946	\N	completed	9
27954	12	480.00	9	2025-07-18 10:47:47.807946	2025-07-18 11:24:47.807946	\N	completed	9
27955	11	315.00	6	2025-07-18 12:23:47.807946	2025-07-18 13:08:47.807946	\N	completed	36
27956	14	675.00	8	2025-07-18 17:31:47.807946	2025-07-18 18:07:47.807946	\N	completed	1
27957	7	825.00	8	2025-07-19 18:20:47.807946	2025-07-19 18:57:47.807946	\N	completed	8
27958	2	360.00	8	2025-07-19 12:54:47.807946	2025-07-19 13:17:47.807946	\N	completed	32
27959	16	285.00	7	2025-07-19 14:21:47.807946	2025-07-19 14:51:47.807946	\N	completed	34
27960	15	600.00	9	2025-07-19 22:03:47.807946	2025-07-19 22:24:47.807946	\N	completed	11
27961	15	260.00	5	2025-07-19 06:54:47.807946	2025-07-19 07:37:47.807946	\N	completed	32
27962	10	1025.00	6	2025-07-19 18:22:47.807946	2025-07-19 19:06:47.807946	\N	completed	34
27963	28	300.00	9	2025-07-19 20:00:47.807946	2025-07-19 20:50:47.807946	\N	completed	36
27964	30	380.00	4	2025-07-19 06:21:47.807946	2025-07-19 07:06:47.807946	\N	completed	34
27965	15	625.00	6	2025-07-19 18:19:47.807946	2025-07-19 19:08:47.807946	\N	completed	1
27966	7	270.00	5	2025-07-19 12:24:47.807946	2025-07-19 13:01:47.807946	\N	completed	10
27967	12	480.00	5	2025-07-19 21:07:47.807946	2025-07-19 21:57:47.807946	\N	completed	1
27968	7	600.00	7	2025-07-19 20:11:47.807946	2025-07-19 20:38:47.807946	\N	completed	32
27969	12	345.00	7	2025-07-19 13:12:47.807946	2025-07-19 13:48:47.807946	\N	completed	10
27970	7	300.00	9	2025-07-19 21:25:47.807946	2025-07-19 21:59:47.807946	\N	completed	10
27971	15	560.00	6	2025-07-19 21:57:47.807946	2025-07-19 22:24:47.807946	\N	completed	9
27972	12	525.00	6	2025-07-19 18:50:47.807946	2025-07-19 19:31:47.807946	\N	completed	3
27973	8	495.00	4	2025-07-19 12:15:47.807946	2025-07-19 12:38:47.807946	\N	completed	1
27974	28	300.00	8	2025-07-19 20:43:47.807946	2025-07-19 21:24:47.807946	\N	completed	8
27975	16	330.00	8	2025-07-19 10:31:47.807946	2025-07-19 11:20:47.807946	\N	completed	9
27976	30	520.00	6	2025-07-19 22:14:47.807946	2025-07-19 22:44:47.807946	\N	completed	10
27977	2	950.00	9	2025-07-19 07:12:47.807946	2025-07-19 07:56:47.807946	\N	completed	3
27978	16	510.00	5	2025-07-19 14:25:47.807946	2025-07-19 14:58:47.807946	\N	completed	36
27979	11	450.00	7	2025-07-19 11:54:47.807946	2025-07-19 12:30:47.807946	\N	completed	36
27980	12	285.00	5	2025-07-19 19:29:47.807946	2025-07-19 20:14:47.807946	\N	completed	9
27981	28	480.00	5	2025-07-19 05:48:47.807946	2025-07-19 06:34:47.807946	\N	completed	36
27982	28	525.00	9	2025-07-19 18:50:47.807946	2025-07-19 19:16:47.807946	\N	completed	8
27983	16	300.00	9	2025-07-19 09:54:47.807946	2025-07-19 10:38:47.807946	\N	completed	36
27984	7	480.00	9	2025-07-19 10:57:47.807946	2025-07-19 11:42:47.807946	\N	completed	10
27985	2	405.00	6	2025-07-19 14:08:47.807946	2025-07-19 14:34:47.807946	\N	completed	10
27986	30	400.00	4	2025-07-19 22:06:47.807946	2025-07-19 22:40:47.807946	\N	completed	34
27987	10	975.00	8	2025-07-20 08:10:47.807946	2025-07-20 08:40:47.807946	\N	completed	32
27988	28	510.00	5	2025-07-20 12:03:47.807946	2025-07-20 12:43:47.807946	\N	completed	9
27989	8	420.00	4	2025-07-20 12:09:47.807946	2025-07-20 12:57:47.807946	\N	completed	11
27990	7	340.00	9	2025-07-20 21:02:47.807946	2025-07-20 21:22:47.807946	\N	completed	10
27991	16	435.00	9	2025-07-20 14:52:47.807946	2025-07-20 15:25:47.807946	\N	completed	1
27992	14	440.00	5	2025-07-20 05:46:47.807946	2025-07-20 06:11:47.807946	\N	completed	8
27993	11	420.00	4	2025-07-20 22:40:47.807946	2025-07-20 23:04:47.807946	\N	completed	10
27994	28	300.00	6	2025-07-20 12:05:47.807946	2025-07-20 12:39:47.807946	\N	completed	1
27995	9	270.00	6	2025-07-20 12:54:47.807946	2025-07-20 13:19:47.807946	\N	completed	8
27996	2	480.00	6	2025-07-20 05:36:47.807946	2025-07-20 06:15:47.807946	\N	completed	32
27997	11	495.00	8	2025-07-20 10:21:47.807946	2025-07-20 10:45:47.807946	\N	completed	11
27998	8	330.00	4	2025-07-20 09:20:47.807946	2025-07-20 10:05:47.807946	\N	completed	1
27999	11	400.00	5	2025-07-20 06:38:47.807946	2025-07-20 07:21:47.807946	\N	completed	34
28000	9	575.00	5	2025-07-20 07:15:47.807946	2025-07-20 07:38:47.807946	\N	completed	8
28001	16	975.00	5	2025-07-20 07:08:47.807946	2025-07-20 07:46:47.807946	\N	completed	11
28002	7	285.00	7	2025-07-20 15:01:47.807946	2025-07-20 15:35:47.807946	\N	completed	8
28003	8	525.00	5	2025-07-20 12:08:47.807946	2025-07-20 12:58:47.807946	\N	completed	10
28004	10	420.00	9	2025-07-20 15:26:47.807946	2025-07-20 16:16:47.807946	\N	completed	10
28005	16	950.00	7	2025-07-20 17:04:47.807946	2025-07-20 17:50:47.807946	\N	completed	8
28006	28	950.00	7	2025-07-20 07:11:47.807946	2025-07-20 07:35:47.807946	\N	completed	32
28007	9	495.00	8	2025-07-20 14:06:47.807946	2025-07-20 14:45:47.807946	\N	completed	3
28008	28	450.00	9	2025-07-20 13:17:47.807946	2025-07-20 13:46:47.807946	\N	completed	34
28009	7	525.00	4	2025-07-21 08:10:47.807946	2025-07-21 08:44:47.807946	\N	completed	9
28010	7	435.00	4	2025-07-21 10:34:47.807946	2025-07-21 11:18:47.807946	\N	completed	10
28011	7	525.00	6	2025-07-21 07:40:47.807946	2025-07-21 08:27:47.807946	\N	completed	32
28012	30	300.00	8	2025-07-21 15:46:47.807946	2025-07-21 16:29:47.807946	\N	completed	32
28013	8	360.00	6	2025-07-21 21:05:47.807946	2025-07-21 21:52:47.807946	\N	completed	1
28014	12	480.00	5	2025-07-21 13:07:47.807946	2025-07-21 13:49:47.807946	\N	completed	9
28015	15	435.00	8	2025-07-21 10:39:47.807946	2025-07-21 11:28:47.807946	\N	completed	8
28016	7	300.00	7	2025-07-21 10:14:47.807946	2025-07-21 10:37:47.807946	\N	completed	34
28017	16	500.00	6	2025-07-21 22:50:47.807946	2025-07-21 23:26:47.807946	\N	completed	10
28018	11	500.00	5	2025-07-21 21:46:47.807946	2025-07-21 22:19:47.807946	\N	completed	11
28019	16	285.00	9	2025-07-21 15:34:47.807946	2025-07-21 16:18:47.807946	\N	completed	9
28020	15	580.00	6	2025-07-21 22:37:47.807946	2025-07-21 23:20:47.807946	\N	completed	32
28021	14	725.00	4	2025-07-21 08:18:47.807946	2025-07-21 08:44:47.807946	\N	completed	11
28022	30	390.00	4	2025-07-21 19:19:47.807946	2025-07-21 20:07:47.807946	\N	completed	11
28023	10	435.00	7	2025-07-21 19:23:47.807946	2025-07-21 20:10:47.807946	\N	completed	1
28024	16	420.00	4	2025-07-21 06:35:47.807946	2025-07-21 07:15:47.807946	\N	completed	34
28025	11	700.00	4	2025-07-21 18:12:47.807946	2025-07-21 18:55:47.807946	\N	completed	6
28026	30	900.00	7	2025-07-21 16:47:47.807946	2025-07-21 17:20:47.807946	\N	completed	34
28027	28	345.00	5	2025-07-21 09:39:47.807946	2025-07-21 10:29:47.807946	\N	completed	1
28028	11	460.00	4	2025-07-21 21:29:47.807946	2025-07-21 21:59:47.807946	\N	completed	10
28029	10	285.00	8	2025-07-21 19:27:47.807946	2025-07-21 20:10:47.807946	\N	completed	8
28030	10	285.00	8	2025-07-21 10:14:47.807946	2025-07-21 10:49:47.807946	\N	completed	32
28031	16	925.00	4	2025-07-21 07:20:47.807946	2025-07-21 07:51:47.807946	\N	completed	1
28032	7	480.00	7	2025-07-21 22:42:47.807946	2025-07-21 23:30:47.807946	\N	completed	6
28033	28	725.00	6	2025-07-22 08:54:47.807946	2025-07-22 09:29:47.807946	\N	completed	8
28034	2	360.00	8	2025-07-22 12:51:47.807946	2025-07-22 13:36:47.807946	\N	completed	36
28035	14	225.00	5	2025-07-22 19:43:47.807946	2025-07-22 20:31:47.807946	\N	completed	32
28036	7	825.00	5	2025-07-22 18:32:47.807946	2025-07-22 18:52:47.807946	\N	completed	10
28037	7	480.00	7	2025-07-22 15:11:47.807946	2025-07-22 15:43:47.807946	\N	completed	10
28038	14	360.00	6	2025-07-22 20:30:47.807946	2025-07-22 20:53:47.807946	\N	completed	11
28039	14	1000.00	8	2025-07-22 08:55:47.807946	2025-07-22 09:44:47.807946	\N	completed	8
28040	12	340.00	6	2025-07-22 20:40:47.807946	2025-07-22 21:25:47.807946	\N	completed	8
28041	9	300.00	8	2025-07-22 21:38:47.807946	2025-07-22 22:27:47.807946	\N	completed	34
28042	7	850.00	4	2025-07-22 18:53:47.807946	2025-07-22 19:43:47.807946	\N	completed	11
28043	14	750.00	8	2025-07-22 07:39:47.807946	2025-07-22 08:16:47.807946	\N	completed	36
28044	11	315.00	4	2025-07-22 19:06:47.807946	2025-07-22 19:29:47.807946	\N	completed	34
28045	2	900.00	6	2025-07-22 18:35:47.807946	2025-07-22 19:00:47.807946	\N	completed	6
28046	9	900.00	5	2025-07-22 16:36:47.807946	2025-07-22 16:56:47.807946	\N	completed	11
28047	9	540.00	8	2025-07-22 21:44:47.807946	2025-07-22 22:13:47.807946	\N	completed	34
28048	11	750.00	5	2025-07-22 16:17:47.807946	2025-07-22 17:05:47.807946	\N	completed	1
28049	7	800.00	6	2025-07-22 08:09:47.807946	2025-07-22 08:44:47.807946	\N	completed	6
28050	12	825.00	6	2025-07-22 18:49:47.807946	2025-07-22 19:12:47.807946	\N	completed	3
28051	2	340.00	4	2025-07-22 22:46:47.807946	2025-07-22 23:23:47.807946	\N	completed	6
28052	30	360.00	4	2025-07-22 15:43:47.807946	2025-07-22 16:06:47.807946	\N	completed	11
28053	14	460.00	7	2025-07-22 06:44:47.807946	2025-07-22 07:20:47.807946	\N	completed	6
28054	9	300.00	5	2025-07-22 05:09:47.807946	2025-07-22 05:51:47.807946	\N	completed	1
28055	15	825.00	8	2025-07-22 18:51:47.807946	2025-07-22 19:16:47.807946	\N	completed	1
28056	2	405.00	6	2025-07-22 12:56:47.807946	2025-07-22 13:37:47.807946	\N	completed	34
28057	12	600.00	4	2025-07-22 16:45:47.807946	2025-07-22 17:32:47.807946	\N	completed	6
28058	12	650.00	9	2025-07-23 17:43:47.807946	2025-07-23 18:25:47.807946	\N	completed	9
28059	15	300.00	9	2025-07-23 14:20:47.807946	2025-07-23 14:57:47.807946	\N	completed	36
28060	16	380.00	9	2025-07-23 22:47:47.807946	2025-07-23 23:36:47.807946	\N	completed	1
28061	14	900.00	7	2025-07-23 08:27:47.807946	2025-07-23 09:05:47.807946	\N	completed	10
28062	9	500.00	4	2025-07-23 20:52:47.807946	2025-07-23 21:14:47.807946	\N	completed	32
28063	16	625.00	4	2025-07-23 18:21:47.807946	2025-07-23 18:59:47.807946	\N	completed	3
28064	10	460.00	9	2025-07-23 05:34:47.807946	2025-07-23 06:07:47.807946	\N	completed	8
28065	2	800.00	8	2025-07-23 07:12:47.807946	2025-07-23 07:46:47.807946	\N	completed	6
28066	7	525.00	7	2025-07-23 08:35:47.807946	2025-07-23 09:00:47.807946	\N	completed	10
28067	10	480.00	8	2025-07-23 06:58:47.807946	2025-07-23 07:42:47.807946	\N	completed	8
28068	11	300.00	4	2025-07-23 12:57:47.807946	2025-07-23 13:36:47.807946	\N	completed	1
28069	7	330.00	9	2025-07-23 10:30:47.807946	2025-07-23 11:11:47.807946	\N	completed	36
28070	8	390.00	5	2025-07-23 11:12:47.807946	2025-07-23 11:58:47.807946	\N	completed	9
28071	7	480.00	4	2025-07-23 21:07:47.807946	2025-07-23 21:40:47.807946	\N	completed	32
28072	11	400.00	9	2025-07-23 20:12:47.807946	2025-07-23 20:32:47.807946	\N	completed	6
28073	2	405.00	5	2025-07-23 12:52:47.807946	2025-07-23 13:24:47.807946	\N	completed	10
28074	14	725.00	5	2025-07-23 16:15:47.807946	2025-07-23 17:03:47.807946	\N	completed	10
28075	16	375.00	6	2025-07-23 11:01:47.807946	2025-07-23 11:25:47.807946	\N	completed	9
28076	9	300.00	5	2025-07-23 09:07:47.807946	2025-07-23 09:33:47.807946	\N	completed	11
28077	2	440.00	9	2025-07-23 05:52:47.807946	2025-07-23 06:33:47.807946	\N	completed	34
28078	11	440.00	4	2025-07-23 20:05:47.807946	2025-07-23 20:54:47.807946	\N	completed	8
28079	7	300.00	8	2025-07-24 13:11:47.807946	2025-07-24 13:43:47.807946	\N	completed	6
28080	10	525.00	7	2025-07-24 17:08:47.807946	2025-07-24 17:47:47.807946	\N	completed	8
28081	7	440.00	7	2025-07-24 20:57:47.807946	2025-07-24 21:34:47.807946	\N	completed	3
28082	8	435.00	9	2025-07-24 11:57:47.807946	2025-07-24 12:34:47.807946	\N	completed	36
28083	28	1025.00	6	2025-07-24 17:31:47.807946	2025-07-24 18:11:47.807946	\N	completed	3
28084	15	875.00	8	2025-07-24 18:09:47.807946	2025-07-24 18:38:47.807946	\N	completed	3
28085	14	625.00	5	2025-07-24 18:03:47.807946	2025-07-24 18:40:47.807946	\N	completed	32
28086	10	850.00	7	2025-07-24 07:57:47.807946	2025-07-24 08:44:47.807946	\N	completed	11
28087	16	550.00	6	2025-07-24 18:52:47.807946	2025-07-24 19:42:47.807946	\N	completed	6
28088	28	435.00	5	2025-07-24 15:09:47.807946	2025-07-24 15:33:47.807946	\N	completed	11
28089	9	525.00	7	2025-07-24 14:56:47.807946	2025-07-24 15:36:47.807946	\N	completed	8
28090	7	420.00	5	2025-07-24 19:36:47.807946	2025-07-24 20:11:47.807946	\N	completed	10
28091	12	550.00	8	2025-07-24 08:52:47.807946	2025-07-24 09:37:47.807946	\N	completed	10
28092	16	285.00	7	2025-07-24 10:57:47.807946	2025-07-24 11:32:47.807946	\N	completed	32
28093	12	520.00	8	2025-07-24 22:57:47.807946	2025-07-24 23:32:47.807946	\N	completed	9
28094	10	435.00	5	2025-07-24 11:41:47.807946	2025-07-24 12:21:47.807946	\N	completed	11
28095	11	525.00	9	2025-07-24 13:02:47.807946	2025-07-24 13:26:47.807946	\N	completed	6
28096	30	510.00	6	2025-07-24 11:21:47.807946	2025-07-24 12:01:47.807946	\N	completed	1
28097	16	270.00	7	2025-07-24 09:26:47.807946	2025-07-24 10:05:47.807946	\N	completed	1
28098	16	510.00	8	2025-07-24 12:33:47.807946	2025-07-24 13:15:47.807946	\N	completed	6
28099	14	360.00	4	2025-07-24 12:29:47.807946	2025-07-24 12:50:47.807946	\N	completed	34
28100	7	340.00	8	2025-07-24 05:40:47.807946	2025-07-24 06:20:47.807946	\N	completed	36
28101	12	330.00	4	2025-07-24 15:00:47.807946	2025-07-24 15:28:47.807946	\N	completed	34
28102	11	480.00	7	2025-07-25 14:38:47.807946	2025-07-25 15:18:47.807946	\N	completed	10
28103	9	460.00	8	2025-07-25 05:35:47.807946	2025-07-25 06:21:47.807946	\N	completed	34
28104	10	420.00	9	2025-07-25 05:56:47.807946	2025-07-25 06:23:47.807946	\N	completed	9
28105	2	1025.00	9	2025-07-25 16:58:47.807946	2025-07-25 17:35:47.807946	\N	completed	32
28106	12	465.00	4	2025-07-25 10:58:47.807946	2025-07-25 11:40:47.807946	\N	completed	1
28107	12	315.00	4	2025-07-25 10:59:47.807946	2025-07-25 11:25:47.807946	\N	completed	9
28108	12	340.00	5	2025-07-25 05:02:47.807946	2025-07-25 05:51:47.807946	\N	completed	36
28109	16	900.00	6	2025-07-25 08:57:47.807946	2025-07-25 09:42:47.807946	\N	completed	8
28110	8	330.00	4	2025-07-25 11:30:47.807946	2025-07-25 12:08:47.807946	\N	completed	10
28111	2	435.00	7	2025-07-25 19:54:47.807946	2025-07-25 20:40:47.807946	\N	completed	36
28112	16	550.00	9	2025-07-25 07:15:47.807946	2025-07-25 07:44:47.807946	\N	completed	11
28113	8	345.00	4	2025-07-25 15:26:47.807946	2025-07-25 15:48:47.807946	\N	completed	32
28114	7	435.00	6	2025-07-25 09:45:47.807946	2025-07-25 10:20:47.807946	\N	completed	36
28115	16	480.00	8	2025-07-25 15:18:47.807946	2025-07-25 15:41:47.807946	\N	completed	9
28116	30	600.00	4	2025-07-25 21:04:47.807946	2025-07-25 21:42:47.807946	\N	completed	9
28117	15	1025.00	8	2025-07-25 08:42:47.807946	2025-07-25 09:30:47.807946	\N	completed	9
28118	10	315.00	8	2025-07-25 14:39:47.807946	2025-07-25 15:03:47.807946	\N	completed	1
28119	10	520.00	5	2025-07-25 21:22:47.807946	2025-07-25 22:03:47.807946	\N	completed	1
28120	12	420.00	7	2025-07-25 15:52:47.807946	2025-07-25 16:36:47.807946	\N	completed	36
28121	11	700.00	5	2025-07-26 17:44:47.807946	2025-07-26 18:25:47.807946	\N	completed	10
28122	14	440.00	5	2025-07-26 22:43:47.807946	2025-07-26 23:22:47.807946	\N	completed	9
28123	2	360.00	7	2025-07-26 11:12:47.807946	2025-07-26 11:52:47.807946	\N	completed	3
28124	11	345.00	7	2025-07-26 12:14:47.807946	2025-07-26 12:54:47.807946	\N	completed	6
28125	7	300.00	8	2025-07-26 06:37:47.807946	2025-07-26 07:17:47.807946	\N	completed	8
28126	28	320.00	7	2025-07-26 05:25:47.807946	2025-07-26 06:14:47.807946	\N	completed	3
28127	11	480.00	8	2025-07-26 13:04:47.807946	2025-07-26 13:28:47.807946	\N	completed	9
28128	16	270.00	4	2025-07-26 12:30:47.807946	2025-07-26 12:50:47.807946	\N	completed	10
28129	7	255.00	5	2025-07-26 19:14:47.807946	2025-07-26 19:48:47.807946	\N	completed	11
28130	28	435.00	7	2025-07-26 14:41:47.807946	2025-07-26 15:03:47.807946	\N	completed	6
28131	7	525.00	8	2025-07-26 11:24:47.807946	2025-07-26 12:13:47.807946	\N	completed	10
28132	28	360.00	8	2025-07-26 10:53:47.807946	2025-07-26 11:28:47.807946	\N	completed	3
28133	7	800.00	7	2025-07-26 16:46:47.807946	2025-07-26 17:29:47.807946	\N	completed	6
28134	2	750.00	4	2025-07-26 17:06:47.807946	2025-07-26 17:32:47.807946	\N	completed	8
28135	15	270.00	7	2025-07-26 11:30:47.807946	2025-07-26 12:15:47.807946	\N	completed	1
28136	16	520.00	5	2025-07-26 22:59:47.807946	2025-07-26 23:38:47.807946	\N	completed	8
28137	12	480.00	4	2025-07-26 21:34:47.807946	2025-07-26 22:18:47.807946	\N	completed	34
28138	30	340.00	9	2025-07-26 06:02:47.807946	2025-07-26 06:34:47.807946	\N	completed	10
28139	10	340.00	6	2025-07-26 05:10:47.807946	2025-07-26 05:48:47.807946	\N	completed	32
28140	15	390.00	6	2025-07-26 19:24:47.807946	2025-07-26 19:53:47.807946	\N	completed	36
28141	7	440.00	6	2025-07-26 20:07:47.807946	2025-07-26 20:35:47.807946	\N	completed	36
28142	10	450.00	6	2025-07-26 19:18:47.807946	2025-07-26 19:43:47.807946	\N	completed	32
28143	10	480.00	8	2025-07-26 14:30:47.807946	2025-07-26 14:57:47.807946	\N	completed	1
28144	15	400.00	5	2025-07-26 22:41:47.807946	2025-07-26 23:15:47.807946	\N	completed	32
28145	10	420.00	4	2025-07-26 12:05:47.807946	2025-07-26 12:29:47.807946	\N	completed	34
28146	15	280.00	7	2025-07-26 05:09:47.807946	2025-07-26 05:41:47.807946	\N	completed	34
28147	12	850.00	5	2025-07-26 08:07:47.807946	2025-07-26 08:36:47.807946	\N	completed	1
28148	30	825.00	7	2025-07-26 17:08:47.807946	2025-07-26 17:34:47.807946	\N	completed	32
28149	10	775.00	5	2025-07-26 08:08:47.807946	2025-07-26 08:36:47.807946	\N	completed	34
28150	16	390.00	5	2025-07-27 10:29:47.807946	2025-07-27 11:16:47.807946	\N	completed	9
28151	11	850.00	5	2025-07-27 16:15:47.807946	2025-07-27 16:50:47.807946	\N	completed	9
28152	12	625.00	8	2025-07-27 16:22:47.807946	2025-07-27 16:42:47.807946	\N	completed	9
28153	30	520.00	9	2025-07-27 21:02:47.807946	2025-07-27 21:33:47.807946	\N	completed	11
28154	16	270.00	9	2025-07-27 13:06:47.807946	2025-07-27 13:43:47.807946	\N	completed	3
28155	16	320.00	7	2025-07-27 06:38:47.807946	2025-07-27 07:19:47.807946	\N	completed	11
28156	28	465.00	5	2025-07-27 10:57:47.807946	2025-07-27 11:24:47.807946	\N	completed	3
28157	11	375.00	7	2025-07-27 10:48:47.807946	2025-07-27 11:25:47.807946	\N	completed	3
28158	16	390.00	6	2025-07-27 15:40:47.807946	2025-07-27 16:12:47.807946	\N	completed	36
28159	16	525.00	4	2025-07-27 10:52:47.807946	2025-07-27 11:37:47.807946	\N	completed	32
28160	11	375.00	4	2025-07-27 15:05:47.807946	2025-07-27 15:29:47.807946	\N	completed	34
28161	15	800.00	7	2025-07-27 07:01:47.807946	2025-07-27 07:27:47.807946	\N	completed	9
28162	30	420.00	7	2025-07-27 21:08:47.807946	2025-07-27 21:35:47.807946	\N	completed	36
28163	7	625.00	4	2025-07-27 17:35:47.807946	2025-07-27 18:24:47.807946	\N	completed	10
28164	10	320.00	4	2025-07-27 21:25:47.807946	2025-07-27 22:00:47.807946	\N	completed	10
28165	8	420.00	9	2025-07-27 11:22:47.807946	2025-07-27 12:04:47.807946	\N	completed	11
28166	11	460.00	8	2025-07-27 22:00:47.807946	2025-07-27 22:21:47.807946	\N	completed	10
28167	12	525.00	8	2025-07-27 11:12:47.807946	2025-07-27 11:47:47.807946	\N	completed	10
28168	11	525.00	8	2025-07-27 18:09:47.807946	2025-07-27 18:50:47.807946	\N	completed	34
28169	30	825.00	6	2025-07-27 17:42:47.807946	2025-07-27 18:08:47.807946	\N	completed	11
28170	16	320.00	4	2025-07-27 22:20:47.807946	2025-07-27 22:57:47.807946	\N	completed	10
28171	9	345.00	5	2025-07-27 11:52:47.807946	2025-07-27 12:18:47.807946	\N	completed	1
28172	14	480.00	4	2025-07-27 06:55:47.807946	2025-07-27 07:39:47.807946	\N	completed	1
28173	15	850.00	4	2025-07-27 07:26:47.807946	2025-07-27 07:52:47.807946	\N	completed	6
28174	16	480.00	6	2025-07-27 21:16:47.807946	2025-07-27 22:02:47.807946	\N	completed	34
28175	16	600.00	6	2025-07-27 22:40:47.807946	2025-07-27 23:12:47.807946	\N	completed	32
28176	15	280.00	9	2025-07-27 06:35:47.807946	2025-07-27 06:57:47.807946	\N	completed	1
28177	15	345.00	9	2025-07-27 09:38:47.807946	2025-07-27 10:16:47.807946	\N	completed	10
28178	12	525.00	4	2025-07-27 18:10:47.807946	2025-07-27 18:54:47.807946	\N	completed	6
28179	9	435.00	8	2025-07-28 13:47:47.807946	2025-07-28 14:32:47.807946	\N	completed	6
28180	11	340.00	9	2025-07-28 21:00:47.807946	2025-07-28 21:28:47.807946	\N	completed	3
28181	9	405.00	8	2025-07-28 15:09:47.807946	2025-07-28 15:40:47.807946	\N	completed	36
28182	30	700.00	9	2025-07-28 07:39:47.807946	2025-07-28 08:16:47.807946	\N	completed	6
28183	2	975.00	7	2025-07-28 16:10:47.807946	2025-07-28 16:55:47.807946	\N	completed	34
28184	14	525.00	8	2025-07-28 13:38:47.807946	2025-07-28 13:58:47.807946	\N	completed	36
28185	9	390.00	7	2025-07-28 14:51:47.807946	2025-07-28 15:29:47.807946	\N	completed	6
28186	2	650.00	4	2025-07-28 07:20:47.807946	2025-07-28 08:06:47.807946	\N	completed	11
28187	11	440.00	7	2025-07-28 22:59:47.807946	2025-07-28 23:49:47.807946	\N	completed	1
28188	16	320.00	6	2025-07-28 21:45:47.807946	2025-07-28 22:34:47.807946	\N	completed	10
28189	16	480.00	9	2025-07-28 09:23:47.807946	2025-07-28 09:59:47.807946	\N	completed	1
28190	30	480.00	6	2025-07-28 13:41:47.807946	2025-07-28 14:10:47.807946	\N	completed	8
28191	30	420.00	8	2025-07-28 05:47:47.807946	2025-07-28 06:32:47.807946	\N	completed	11
28192	12	315.00	9	2025-07-28 10:00:47.807946	2025-07-28 10:24:47.807946	\N	completed	10
28193	16	460.00	4	2025-07-28 06:43:47.807946	2025-07-28 07:33:47.807946	\N	completed	3
28194	9	420.00	4	2025-07-28 12:11:47.807946	2025-07-28 12:53:47.807946	\N	completed	34
28195	15	460.00	6	2025-07-28 20:03:47.807946	2025-07-28 20:43:47.807946	\N	completed	32
28196	16	420.00	8	2025-07-28 15:09:47.807946	2025-07-28 15:30:47.807946	\N	completed	8
28197	7	1000.00	7	2025-07-28 07:35:47.807946	2025-07-28 07:56:47.807946	\N	completed	34
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.users (id, username, first_name, second_name, password, email, phone_number, driver_licence, status, role) FROM stdin;
9	driver5	David	Kipchoge	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	harmanhamoso1@gmail.com	0711234003	DL001236	ACTIVE	DRIVER
1	Admin	Olal	Ochienga	PBKDF2WithHmacSHA256:2048:mJj7MzOcTnsdiT+2W7dtSIU8MljalkdKXpF8SdLfd9Y=:bGPulyW/7Qj5f0TGS0hr+nqP9oNiLKvhQsTqzCEB7oE=	olalsamuel01@gmail.com	+1 231212122312121	12323123123	ACTIVE	ADMIN
27	driver21	\N	\N	PBKDF2WithHmacSHA256:2048:pHwbqTEov+iy003o0bHKMlcI7AltIbyo2laApgUyZJ0=:4/46sZi/BvkDCFv2nGXV8JnDZQAZ7K36nmigA+6RfVA=	olalsamy8@gmail.com	\N	\N	ACTIVE	ADMIN
7	driver3	John	Mwangi	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	driver3@nganya.com	0711234001	DL001234	ACTIVE	DRIVER
8	driver4	Catherine	Wanjiku	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	driver4@nganya.com	0711234002	DL001235	ACTIVE	DRIVER
10	driver6	Faith	Njeri	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	driver6@nganya.com	0711234004	DL001237	ACTIVE	DRIVER
11	driver7	George	Omondi	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	driver7@nganya.com	0711234005	DL001238	ACTIVE	DRIVER
12	driver8	Hellen	Kamau	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	driver8@nganya.com	0711234006	DL001239	ACTIVE	DRIVER
14	driver10	Joyce	Waithera	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	driver10@nganya.com	0711234008	DL001241	ACTIVE	DRIVER
31	1	\N	\N	PBKDF2WithHmacSHA256:2048:G1Bc7D/OHjDGkac58tvMFWTml9FPYGmO0SVG6k9zPK4=:JHI+6jGoS0mcRAJ4mf+DUibks1SqOIpjp/Pnv29174I=	olalsam@gmail.com	\N	\N	ACTIVE	ADMIN
15	driver11	Kennedy	Otieno	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	driver11@nganya.com	0711234009	DL001242	ACTIVE	DRIVER
2	driver1	samuel	Olal	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	olal01101001@gmail.com	0112342233	123122434	ACTIVE	DRIVER
30	Samuel	samuel	Olal	PBKDF2WithHmacSHA256:2048:KbcJZ6Ec28p6Rv2GZSRGMAd8gRFnjCZ5ah4lT21QtOU=:mrjYT+hjgpLYLh3SW6nXNtErhq7xIyH9Qk+xiuzo5G8=	Samuel@nganya.com	0112340731	393010133	ACTIVE	DRIVER
28	adminsa	samuel	Olal	PBKDF2WithHmacSHA256:2048:AKZEfqeH/YdoyfVlOa3gpqVCjkhsb8HHx/RiHCnTxSk=:OYCfIj15u7OW9cB7vnYo1DcV0aeDUr4LG3S1pmLaKRs=	adminsa@nganya.com	0112340733	12349584	INACTIVE	DRIVER
13	driver9	Isaac	Mutua	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	driver9@nganya.com	0711234007	DL001240	INACTIVE	DRIVER
4	driver2			PBKDF2WithHmacSHA256:2048:FwrbBbZW7rKuef2WPjWEVI7Wwj34zywS6tsEqCeRiHg=:rsHu18CYQH8lfkTo671Ny98Wr2GdVXFbFrym8lry0ts=	driver2@nganya.com			INACTIVE	DRIVER
16	driver12	Lucy	Akinyi	PBKDF2WithHmacSHA256:2048:JK+ib/cl/2LMMOwMIhXmQaV5iYvtCr73jQDV8rBLXes=:cRWcMc9oeP+tI27O+unrKzDup3W8eSHpv0fE2LMwl2s=	judithouma2030@gmail.com	0711234011	DL0012435	ACTIVE	DRIVER
\.


--
-- Data for Name: vehicle; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.vehicle (id, plate_number, vehicle_model, owner_national_id, capacity, sacco, status, lastmaintainance) FROM stdin;
11	KDB 345G	Isuzu NQR	78901234	33	Rembo Shuttle	available	\N
12	KDH 678H	Mercedes Benz MB917	89012345	37	Embakasi Shuttle	available	\N
13	KCC 901J	Toyota Coaster	90123456	29	Rwanda Sacco	available	\N
14	KDJ 234K	Mitsubishi Rosa	01234567	26	Super Metro	available	\N
15	KDF 567L	Isuzu FRR	12345670	33	Mwiki Sacco	available	\N
16	KCA 890M	Nissan Civilian	23456701	30	Kayole Shuttle	available	\N
5	KDD 123A	Isuzu NQR	12345678	33	Super Metros	available	\N
19	KDL 789Q	Hino 500	56701234w	44	KBS	available	\N
20	KSQ-2313	Tx	1234565	44	Royal Swift	available	\N
22	KSQ-2315	isu	123445	44	Royal	available	\N
24	KSQ-2312	Tx	12345221	55	Royal Swift	available	\N
26	KSQ-231512	isuzu	123456	33	Royal Swift	available	\N
28	KSQ-2310	isuzu	123456	33	Royal Swift	available	\N
30	KSQ-2311	isuzu	123456	33	Royal Swift	available	\N
32	KSQ-2399	isuzu	123456	33	Royal Swift	available	\N
34	KSQ-23994	isuzu	123456	33	Royal Swift	available	\N
38	KSQ-3120	isuzu	123456	21	Royal Swift	available	\N
18	KCB 456P	Isuzu NQR	45670123	33	Utawala Sacco	available	\N
7	KBZ 789C	Mitsubishi Fuso	34567890	41	Embassava Sacco	available	\N
6	KCE 456B	Toyota Coaster	23456789	29	Forward Travelers	available	\N
36	KSQ-3212	isuzu	123456	33	Royal Swift	available	\N
17	KDK 123N	Toyota Coaster	34567012	29	City Shuttle	available	\N
8	KDE 234D	Isuzu FRR	45678901	33	Metro Trans	available	\N
3	KWS 42161	Isuzu	1233910	56	Royal Swift	available	\N
1	KWS 4216	Isuzu	1233910	40	Royal Swift	available	\N
10	KCF 890F	Toyota Hiace	67890123	14	Lopha Sacco	available	\N
9	KDG 567E	Hino 300	56789012	25	Umoja Innercore Sacco	assigned	\N
\.


--
-- Data for Name: vehicle_assignments; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.vehicle_assignments (id, vehicle_id, driver_id, start_date, end_date, status) FROM stdin;
4	1	2	2025-03-23 00:00:00+03	2025-03-29 00:00:00+03	completed
5	3	4	2025-03-24 00:00:00+03	2025-03-29 00:00:00+03	completed
7	1	2	2025-04-01 00:00:00+03	2025-03-08 00:00:00+03	completed
9	13	15	2025-04-29 00:00:00+03	2025-05-06 00:00:00+03	completed
10	19	15	2025-04-29 00:00:00+03	2025-05-06 00:00:00+03	completed
11	18	14	2025-04-29 00:00:00+03	2025-05-06 00:00:00+03	completed
12	16	13	2025-04-29 00:00:00+03	2025-05-06 00:00:00+03	completed
13	15	12	2025-04-29 00:00:00+03	2025-05-06 00:00:00+03	completed
14	12	11	2025-04-29 00:00:00+03	2025-05-06 00:00:00+03	completed
15	11	10	2025-04-29 00:00:00+03	2025-05-06 00:00:00+03	completed
8	6	8	2025-05-01 00:00:00+03	2025-05-17 00:00:00+03	completed
18	7	2	2025-05-23 00:00:00+03	2025-05-31 00:00:00+03	cancelled
17	18	7	2025-05-11 00:00:00+03	2025-05-24 00:00:00+03	cancelled
16	1	4	2025-05-08 00:00:00+03	2025-05-15 00:00:00+03	cancelled
20	7	30	2025-06-03 00:00:00+03	2025-06-14 00:00:00+03	cancelled
19	18	2	2025-06-10 00:00:00+03	2025-06-20 00:00:00+03	cancelled
26	7	4	2025-06-05 00:00:00+03	2025-06-09 00:00:00+03	cancelled
27	1	2	2025-06-05 00:00:00+03	2025-06-11 00:00:00+03	cancelled
21	6	9	2025-06-22 00:00:00+03	2025-06-16 00:00:00+03	cancelled
25	36	28	2025-06-22 00:00:00+03	2025-06-16 00:00:00+03	cancelled
24	17	30	2025-06-22 00:00:00+03	2025-06-16 00:00:00+03	cancelled
22	8	10	2025-06-22 00:00:00+03	2025-06-16 00:00:00+03	cancelled
23	3	16	2025-06-22 00:00:00+03	2025-06-16 00:00:00+03	cancelled
29	1	2	2025-06-15 00:00:00+03	2025-06-23 00:00:00+03	cancelled
28	10	2	2025-06-04 00:00:00+03	2025-06-11 00:00:00+03	cancelled
30	9	9	2025-07-28 00:00:00+03	2025-08-02 00:00:00+03	active
\.


--
-- Data for Name: vehicle_history; Type: TABLE DATA; Schema: public; Owner: olal
--

COPY public.vehicle_history (id, driver_id, vehicle_id, latitude, "timestamp", longitude) FROM stdin;
1	2	1	-4.05466	2025-05-06 09:19:16.234842	39.6636
2	2	1	-4.05466	2025-05-06 09:22:24.128962	39.6636
3	2	1	-4.05466	2025-05-06 09:22:50.154059	39.6636
4	2	1	-4.05466	2025-05-06 09:27:25.217081	39.6636
5	2	1	-4.05466	2025-05-06 09:27:51.157548	39.6636
6	2	1	-4.05466	2025-05-06 09:28:17.966616	39.6636
7	2	1	-4.05466	2025-05-06 09:32:28.640058	39.6636
8	2	1	-4.05466	2025-05-06 09:33:07.1238	39.6636
9	2	1	-4.05466	2025-05-06 09:34:25.287839	39.6636
10	2	1	-4.05466	2025-05-06 09:38:05.500923	39.6636
11	2	1	-4.05466	2025-05-06 09:38:33.027533	39.6636
12	2	1	-4.05466	2025-05-06 09:38:58.445539	39.6636
13	2	1	-4.05466	2025-05-06 09:39:38.300756	39.6636
14	2	1	-4.05466	2025-05-06 09:40:14.501402	39.6636
15	2	1	-4.05466	2025-05-06 09:40:40.540483	39.6636
16	2	1	-4.05466	2025-05-06 09:41:06.315226	39.6636
17	2	1	-4.05466	2025-05-06 09:41:32.439476	39.6636
18	2	1	-4.05466	2025-05-06 09:42:24.225727	39.6636
19	2	1	-4.05466	2025-05-06 09:42:51.486145	39.6636
20	2	1	-4.05466	2025-05-06 09:43:24.140264	39.6636
21	2	1	-4.05466	2025-05-06 09:43:49.665556	39.6636
22	2	1	-4.05466	2025-05-06 09:44:07.195853	39.6636
23	2	1	-4.05466	2025-05-06 09:44:33.289603	39.6636
24	2	1	-4.05466	2025-05-06 09:44:59.211312	39.6636
25	2	1	-4.05466	2025-05-06 09:45:26.438552	39.6636
26	2	1	-4.05466	2025-05-06 09:45:52.206603	39.6636
27	2	1	-4.05466	2025-05-06 09:46:42.601361	39.6636
28	2	1	-4.05466	2025-05-06 10:22:06.366569	39.6636
29	2	1	-4.05466	2025-05-06 10:22:36.361026	39.6636
30	2	1	-4.05466	2025-05-06 10:23:42.219847	39.6636
31	2	1	-4.05466	2025-05-06 10:24:08.217927	39.6636
32	2	1	-4.05466	2025-05-06 10:24:35.42173	39.6636
33	2	1	-4.05466	2025-05-06 10:25:00.157186	39.6636
34	2	1	-4.05466	2025-05-06 10:25:26.800245	39.6636
35	2	1	-4.05466	2025-05-06 10:26:05.217392	39.6636
36	2	1	-4.05466	2025-05-06 10:26:31.133834	39.6636
37	2	1	-4.05466	2025-05-06 10:27:10.253727	39.6636
38	2	1	-4.05466	2025-05-06 10:27:36.419355	39.6636
39	2	1	-4.05466	2025-05-06 12:28:25.793932	39.6636
40	2	1	-4.05466	2025-05-06 12:28:46.111255	39.6636
41	2	1	-4.05466	2025-05-06 12:29:10.940818	39.6636
42	2	1	-4.05466	2025-05-06 12:29:32.974683	39.6636
43	2	1	-4.05466	2025-05-06 12:29:55.074188	39.6636
44	2	1	-4.05466	2025-05-06 12:30:25.027063	39.6636
45	2	1	-4.05466	2025-05-06 12:31:10.359571	39.6636
46	2	1	-4.05466	2025-05-06 12:31:34.835833	39.6636
47	2	1	-4.05466	2025-05-06 12:31:59.678033	39.6636
48	2	1	-4.05466	2025-05-06 12:32:39.938876	39.6636
49	2	1	-4.05466	2025-05-06 12:33:06.389652	39.6636
50	2	1	-4.05466	2025-05-06 12:34:15.683024	39.6636
51	2	1	-4.05466	2025-05-06 12:34:38.496966	39.6636
52	2	1	-4.05466	2025-05-06 12:35:27.915017	39.6636
53	2	1	-4.05466	2025-05-06 12:35:54.896105	39.6636
54	2	1	-4.05466	2025-05-06 12:36:21.978892	39.6636
55	2	1	-4.05466	2025-05-06 12:36:51.816345	39.6636
56	2	1	-4.05466	2025-05-06 12:37:13.600905	39.6636
57	2	1	-4.05466	2025-05-06 12:38:55.484482	39.6636
58	2	1	-4.05466	2025-05-06 12:39:00.073698	39.6636
59	2	1	-4.05466	2025-05-06 12:39:28.467791	39.6636
60	2	1	-4.05466	2025-05-06 12:39:52.768868	39.6636
61	2	1	-4.05466	2025-05-06 12:40:17.622348	39.6636
62	2	1	-4.05466	2025-05-06 12:40:48.16952	39.6636
63	2	1	-4.05466	2025-05-06 12:41:12.670665	39.6636
64	2	1	-4.05466	2025-05-06 12:41:52.999668	39.6636
65	2	1	-4.05466	2025-05-06 12:42:56.722036	39.6636
66	2	1	-4.05466	2025-05-06 12:43:43.684508	39.6636
67	2	1	-4.05466	2025-05-06 12:44:27.515124	39.6636
68	2	1	-4.05466	2025-05-06 12:45:00.912753	39.6636
69	2	1	-4.05466	2025-05-06 12:45:30.572618	39.6636
70	2	1	-4.05466	2025-05-06 12:45:50.653448	39.6636
71	2	1	-4.05466	2025-05-06 12:46:16.720488	39.6636
72	2	1	-4.05466	2025-05-06 12:46:36.981362	39.6636
73	2	1	-4.05466	2025-05-06 12:48:04.298591	39.6636
74	2	1	-4.05466	2025-05-06 12:48:35.809648	39.6636
75	2	1	-4.05466	2025-05-06 12:48:59.968912	39.6636
76	2	1	-4.05466	2025-05-06 12:49:41.657543	39.6636
77	2	1	-4.05466	2025-05-06 12:50:09.953361	39.6636
78	2	1	-4.05466	2025-05-06 12:50:36.726073	39.6636
79	2	1	-4.05466	2025-05-06 12:51:08.066987	39.6636
80	2	1	-4.05466	2025-05-06 12:51:28.62458	39.6636
81	2	1	-4.05466	2025-05-06 12:51:56.84399	39.6636
82	2	1	-4.05466	2025-05-06 12:52:24.72674	39.6636
83	2	1	-4.05466	2025-05-06 12:53:09.325228	39.6636
84	2	1	-4.05466	2025-05-06 12:54:07.899846	39.6636
85	2	1	-4.05466	2025-05-06 12:54:34.966249	39.6636
86	2	1	-4.05466	2025-05-06 12:54:59.672111	39.6636
87	2	1	-4.05466	2025-05-06 12:55:28.981599	39.6636
88	2	1	-4.05466	2025-05-06 12:56:03.016454	39.6636
89	2	1	-4.05466	2025-05-06 12:56:32.653184	39.6636
90	2	1	-4.05466	2025-05-06 12:56:58.889712	39.6636
91	2	1	-4.05466	2025-05-06 12:57:37.698676	39.6636
92	2	1	-4.05466	2025-05-06 12:58:12.687171	39.6636
93	2	1	-4.05466	2025-05-06 12:58:43.905721	39.6636
94	2	1	-4.05466	2025-05-06 12:59:09.216363	39.6636
95	2	1	-4.05466	2025-05-06 12:59:35.574403	39.6636
96	2	1	-4.05466	2025-05-06 12:59:57.919125	39.6636
97	2	1	-4.05466	2025-05-06 13:00:36.78435	39.6636
98	2	1	-4.05466	2025-05-06 13:01:27.513088	39.6636
99	2	1	-4.05466	2025-05-06 13:02:15.691581	39.6636
100	2	1	-4.05466	2025-05-06 13:02:46.825029	39.6636
101	2	1	-4.05466	2025-05-06 13:03:22.018672	39.6636
102	2	1	-4.05466	2025-05-06 13:04:13.19868	39.6636
103	2	1	-4.05466	2025-05-06 13:04:54.70978	39.6636
104	2	1	-4.05466	2025-05-06 13:05:19.663087	39.6636
105	2	1	-4.05466	2025-05-06 13:08:06.398812	39.6636
106	2	1	-4.05466	2025-05-06 13:08:52.470723	39.6636
107	2	1	-4.05466	2025-05-06 13:09:17.927121	39.6636
108	2	1	-4.05466	2025-05-06 13:09:56.902867	39.6636
109	2	1	-4.05466	2025-05-06 13:10:51.216432	39.6636
110	2	1	-4.05466	2025-05-06 13:11:32.685526	39.6636
111	2	1	-4.05466	2025-05-06 13:11:58.912292	39.6636
112	2	1	-4.05466	2025-05-06 13:12:22.863713	39.6636
113	2	1	-4.05466	2025-05-06 13:12:48.735238	39.6636
114	2	1	-4.05466	2025-05-06 13:13:31.013955	39.6636
115	2	1	-4.05466	2025-05-06 13:14:22.002949	39.6636
116	2	1	-4.05466	2025-05-06 13:15:05.265004	39.6636
117	2	1	-4.05466	2025-05-06 13:16:12.978508	39.6636
118	2	1	-4.05466	2025-05-06 13:20:28.616916	39.6636
119	2	1	-4.05466	2025-05-06 13:21:00.813721	39.6636
120	2	1	-4.05466	2025-05-06 13:21:39.809007	39.6636
121	2	1	-4.05466	2025-05-06 13:22:05.737235	39.6636
122	2	1	-4.05466	2025-05-06 13:22:44.615532	39.6636
123	2	1	-1.2841	2025-05-06 14:30:24.993776	36.8155
124	2	1	-1.2841	2025-05-06 14:55:50.83335	36.8155
125	2	1	-4.05466	2025-05-06 15:23:59.14893	39.6636
126	2	1	-4.05466	2025-05-06 15:24:05.374627	39.6636
127	2	1	-4.05466	2025-05-06 15:24:15.789354	39.6636
128	2	1	-4.05466	2025-05-06 15:24:28.800808	39.6636
129	2	1	-4.05466	2025-05-06 15:24:54.850225	39.6636
130	2	1	-4.05466	2025-05-06 15:25:07.882912	39.6636
131	2	1	-4.05466	2025-05-06 15:30:52.687214	39.6636
132	2	1	-4.05466	2025-05-06 15:30:59.235363	39.6636
133	2	1	-4.05466	2025-05-06 15:38:19.693437	39.6636
134	2	1	-4.05466	2025-05-06 15:38:25.671846	39.6636
135	2	1	-4.05466	2025-05-06 15:38:36.487352	39.6636
136	2	1	-4.05466	2025-05-06 15:38:49.281873	39.6636
137	2	1	-4.05466	2025-05-06 15:39:15.36378	39.6636
138	2	1	-4.05466	2025-05-06 15:39:27.185184	39.6636
139	2	1	-4.05466	2025-05-06 15:39:39.499802	39.6636
140	2	1	-4.05466	2025-05-06 15:40:19.078942	39.6636
141	2	1	-4.05466	2025-05-06 15:40:31.172919	39.6636
142	2	1	-4.05466	2025-05-06 15:41:10.562363	39.6636
143	2	1	-4.05466	2025-05-06 15:41:25.426108	39.6636
144	2	1	-4.05466	2025-05-06 15:41:37.564025	39.6636
145	2	1	-4.05466	2025-05-06 15:41:50.327412	39.6636
146	2	1	-4.05466	2025-05-06 15:42:03.162234	39.6636
147	2	1	-4.05466	2025-05-06 15:42:55.08007	39.6636
148	2	1	-4.05466	2025-05-06 15:43:22.814764	39.6636
149	2	1	-4.05466	2025-05-06 15:43:46.73723	39.6636
150	2	1	-4.05466	2025-05-06 15:44:13.625738	39.6636
151	2	1	-4.05466	2025-05-06 15:44:38.946315	39.6636
152	2	1	-4.05466	2025-05-06 15:45:04.769557	39.6636
153	2	1	-4.05466	2025-05-06 15:45:18.881632	39.6636
154	2	1	-4.05466	2025-05-06 15:45:33.005958	39.6636
155	2	1	-4.05466	2025-05-06 15:45:44.478987	39.6636
156	2	1	-4.05466	2025-05-06 15:45:58.953403	39.6636
157	2	1	-4.05466	2025-05-06 15:46:23.223192	39.6636
158	2	1	-4.05466	2025-05-06 15:46:35.924639	39.6636
159	2	1	-4.05466	2025-05-06 15:46:48.791978	39.6636
160	2	1	-4.05466	2025-05-06 15:47:02.745892	39.6636
161	2	1	-4.05466	2025-05-06 15:47:19.51864	39.6636
162	2	1	-4.05466	2025-05-06 15:47:31.573008	39.6636
163	2	1	-4.05466	2025-05-06 15:47:43.364407	39.6636
164	2	1	-4.05466	2025-05-06 15:47:56.672105	39.6636
165	2	1	-4.05466	2025-05-06 15:52:13.618907	39.6636
166	2	1	-4.05466	2025-05-06 15:52:30.732076	39.6636
167	2	1	-4.05466	2025-05-06 15:52:43.803285	39.6636
168	2	1	-4.05466	2025-05-06 15:52:56.692416	39.6636
169	2	1	-4.05466	2025-05-06 15:53:21.867431	39.6636
170	2	1	-4.05466	2025-05-06 15:53:34.645912	39.6636
171	2	1	-4.05466	2025-05-06 15:53:48.071924	39.6636
172	2	1	-4.05466	2025-05-06 15:55:06.632673	39.6636
173	2	1	-4.05466	2025-05-06 15:55:24.118531	39.6636
174	2	1	-4.05466	2025-05-06 15:55:37.700714	39.6636
175	2	1	-4.05466	2025-05-06 15:56:22.756655	39.6636
176	2	1	-4.05466	2025-05-06 15:56:36.269382	39.6636
177	2	1	-4.05466	2025-05-06 15:56:43.214266	39.6636
178	2	1	-4.05466	2025-05-06 15:57:22.63994	39.6636
179	2	1	-4.05466	2025-05-06 15:57:35.149778	39.6636
180	2	1	-4.05466	2025-05-06 15:58:17.627114	39.6636
181	2	1	-4.05466	2025-05-06 15:58:31.425232	39.6636
182	2	1	-4.05466	2025-05-06 15:58:57.463053	39.6636
183	2	1	-4.05466	2025-05-06 15:59:10.975736	39.6636
184	2	1	-4.05466	2025-05-06 15:59:35.057463	39.6636
185	2	1	-4.05466	2025-05-06 16:48:12.609937	39.6636
186	2	1	-4.05466	2025-05-06 16:48:38.133096	39.6636
187	2	1	-4.05466	2025-05-06 17:30:11.410817	39.6636
188	2	1	-4.05466	2025-05-06 18:22:16.734913	39.6636
189	2	1	-4.05466	2025-05-06 18:35:51.189064	39.6636
190	2	1	-4.05466	2025-05-06 18:50:23.179494	39.6636
191	2	1	-4.05466	2025-05-06 19:18:54.701314	39.6636
192	2	1	-4.05466	2025-05-06 19:21:10.932085	39.6636
193	2	1	-4.05466	2025-05-06 19:24:26.948763	39.6636
194	2	1	-4.05466	2025-05-06 19:32:34.456456	39.6636
195	2	1	-1.2841	2025-05-07 05:42:51.727327	36.8155
196	2	1	-1.2841	2025-05-07 05:42:56.437682	36.8155
197	2	1	-1.2841	2025-05-07 06:48:47.973807	36.8155
198	2	1	-1.2841	2025-05-07 06:50:00.566642	36.8155
199	2	0	-1.29207	2025-05-23 13:38:18.310138	36.8219
200	2	0	-1.29207	2025-05-23 13:38:18.333992	36.8219
201	2	0	-1.29207	2025-05-23 13:38:18.342244	36.8219
202	2	0	-1.29207	2025-05-23 13:38:18.351556	36.8219
203	2	0	-1.29207	2025-05-23 13:38:28.531634	36.8219
204	2	0	-1.29207	2025-05-23 13:38:46.277593	36.8219
205	2	0	-1.29207	2025-05-23 13:38:59.312907	36.8219
206	2	0	-1.29207	2025-05-23 13:39:12.306737	36.8219
207	2	0	-1.29207	2025-05-23 13:39:25.323899	36.8219
208	2	0	-1.29207	2025-05-23 13:39:38.416509	36.8219
209	2	0	-1.29207	2025-05-23 13:39:52.049215	36.8219
210	2	0	-1.29207	2025-05-23 13:40:17.222627	36.8219
211	2	0	-1.29207	2025-05-23 13:40:30.201002	36.8219
212	2	0	-1.29207	2025-05-23 13:40:43.387561	36.8219
213	2	0	-1.29207	2025-05-23 13:40:56.272608	36.8219
214	2	0	-1.29207	2025-05-23 14:22:59.622136	36.8219
215	2	0	-1.29207	2025-05-23 14:23:17.313217	36.8219
216	2	0	-1.29207	2025-05-23 14:23:30.255464	36.8219
217	2	0	-1.29207	2025-05-23 14:24:09.263895	36.8219
218	2	0	-1.29207	2025-05-23 14:24:22.253994	36.8219
219	2	0	-1.29207	2025-05-23 14:24:35.267635	36.8219
220	2	0	-1.29207	2025-05-23 14:24:48.248105	36.8219
221	2	0	-1.29207	2025-05-23 14:25:01.283102	36.8219
222	2	0	-1.29207	2025-05-23 14:25:14.271261	36.8219
223	2	7	-1.29207	2025-05-23 14:25:27.269993	36.8219
224	2	7	-1.29207	2025-05-23 14:26:06.334963	36.8219
225	2	7	-1.29207	2025-05-23 14:26:23.337897	36.8219
226	2	7	-1.29207	2025-05-23 14:26:36.296572	36.8219
227	2	7	-1.29207	2025-05-23 14:27:02.20901	36.8219
228	2	7	-1.29207	2025-05-23 14:27:41.429178	36.8219
229	2	7	-1.29207	2025-05-23 14:27:54.297792	36.8219
230	2	7	-1.29207	2025-05-23 14:28:46.366644	36.8219
231	2	7	-1.29207	2025-05-23 14:28:59.110015	36.8219
232	2	7	-1.29207	2025-05-23 14:29:12.288381	36.8219
233	2	7	-1.29207	2025-05-23 14:29:38.301919	36.8219
234	2	7	-1.29207	2025-05-23 14:30:04.281396	36.8219
235	2	7	-1.29207	2025-05-23 14:30:17.269133	36.8219
236	2	7	-1.29207	2025-05-23 14:30:30.294661	36.8219
237	2	7	-1.29207	2025-05-23 14:30:43.262737	36.8219
238	2	7	-1.29207	2025-05-23 14:31:09.291144	36.8219
239	2	7	-1.29207	2025-05-23 14:31:22.278908	36.8219
240	2	7	-1.29207	2025-05-23 14:32:01.299505	36.8219
241	2	7	-1.29207	2025-05-23 14:32:14.301181	36.8219
242	2	7	-1.29207	2025-05-23 14:32:27.319929	36.8219
243	2	7	-1.29207	2025-05-23 14:32:39.358113	36.8219
244	2	7	-1.29207	2025-05-23 14:32:53.229437	36.8219
245	2	7	-1.29207	2025-05-23 14:33:32.226358	36.8219
246	2	7	-1.29207	2025-05-23 14:34:11.200457	36.8219
247	2	7	-1.29207	2025-05-23 14:35:03.303694	36.8219
248	2	7	-1.29207	2025-05-23 14:35:16.236741	36.8219
249	2	7	-1.29207	2025-05-23 14:35:29.312326	36.8219
250	2	7	-1.29207	2025-05-23 14:35:55.262681	36.8219
251	2	7	-1.29207	2025-05-23 14:36:08.260841	36.8219
252	2	7	-1.29207	2025-05-23 14:36:21.215719	36.8219
253	2	7	-1.29207	2025-05-23 14:37:13.333419	36.8219
254	2	7	-1.29207	2025-05-23 14:37:26.704414	36.8219
255	2	7	-1.29207	2025-05-23 14:38:05.268614	36.8219
256	2	7	-1.29207	2025-05-23 14:38:18.232643	36.8219
257	2	7	-1.29207	2025-05-23 14:38:57.207137	36.8219
258	2	7	-1.29207	2025-05-23 14:39:36.281948	36.8219
259	2	7	-1.29207	2025-05-23 14:39:49.306102	36.8219
260	2	7	-1.29207	2025-05-23 14:40:02.283472	36.8219
261	2	7	-1.29207	2025-05-23 14:40:15.298419	36.8219
262	2	7	-1.29207	2025-05-23 14:40:28.228024	36.8219
263	2	7	-1.29207	2025-05-23 14:40:41.296811	36.8219
264	2	18	-1.2841	2025-05-30 09:25:53.345378	36.8155
265	2	18	-1.2841	2025-05-30 09:34:16.298453	36.8155
266	2	18	-1.2841	2025-05-30 09:45:39.377439	36.8155
267	2	18	-1.2841	2025-05-30 16:46:10.66373	36.8155
268	2	18	-1.2841	2025-05-30 17:25:50.437956	36.8155
269	2	18	-1.2841	2025-05-31 17:15:48.510313	36.8155
270	2	18	-1.2841	2025-05-31 17:51:50.093332	36.8155
271	2	18	-1.2841	2025-05-31 17:52:54.198689	36.8155
272	2	18	-1.2841	2025-05-31 17:53:44.965204	36.8155
273	2	18	-1.2841	2025-05-31 18:10:52.12678	36.8155
274	2	18	-1.2841	2025-05-31 18:12:38.571809	36.8155
275	2	18	-1.2841	2025-05-31 18:34:57.586177	36.8155
276	2	18	-1.2841	2025-05-31 18:35:43.455412	36.8155
277	2	18	-1.2841	2025-05-31 18:41:18.451348	36.8155
278	2	18	-1.2841	2025-05-31 19:20:02.494804	36.8155
279	2	18	-1.2841	2025-05-31 19:20:08.337407	36.8155
280	2	18	-1.2841	2025-05-31 19:25:45.894637	36.8155
281	2	18	-1.2841	2025-05-31 19:26:20.850178	36.8155
282	2	0	-1.2841	2025-06-04 02:23:04.473641	36.8155
283	2	0	-1.2841	2025-06-04 02:23:14.624359	36.8155
284	2	0	-1.2841	2025-06-04 02:24:25.971578	36.8155
285	2	0	-1.2841	2025-06-04 02:24:52.628401	36.8155
286	2	1	-1.2841	2025-06-04 02:30:59.660491	36.8155
287	2	1	-1.2841	2025-06-04 02:32:12.093492	36.8155
288	2	1	-1.2841	2025-06-04 02:32:37.626473	36.8155
289	2	1	-1.2841	2025-06-04 02:35:12.334292	36.8155
290	2	1	-1.2841	2025-06-04 02:44:34.540804	36.8155
291	2	1	-1.2841	2025-06-04 02:50:58.649223	36.8155
292	2	1	-1.2841	2025-06-04 02:55:14.020961	36.8155
293	2	1	-1.2841	2025-06-04 03:07:51.818267	36.8155
294	2	1	-1.2841	2025-06-04 03:28:49.174449	36.8155
295	2	1	-1.2841	2025-06-04 03:36:27.134789	36.8155
296	2	1	-1.29207	2025-06-04 07:55:01.269441	36.8219
297	2	1	-1.29207	2025-06-04 07:55:23.825275	36.8219
298	2	1	-1.29207	2025-06-04 07:56:57.828773	36.8219
299	2	1	-1.29207	2025-06-04 07:57:13.127895	36.8219
300	2	1	-1.29207	2025-06-04 07:57:32.130461	36.8219
301	2	1	-1.29207	2025-06-04 07:57:32.173007	36.8219
302	2	1	-1.29207	2025-06-04 07:57:55.864806	36.8219
303	2	1	-1.29207	2025-06-04 07:58:23.47549	36.8219
304	2	1	-1.29207	2025-06-04 07:59:11.949351	36.8219
305	2	1	-1.29207	2025-06-04 07:59:36.767675	36.8219
306	2	1	-1.29207	2025-06-04 07:59:55.429246	36.8219
307	2	10	-1.29207	2025-06-04 09:49:19.987939	36.8219
308	2	10	-1.29207	2025-06-04 09:49:25.488978	36.8219
309	2	10	-1.29207	2025-06-04 09:49:54.924715	36.8219
310	2	10	-1.29207	2025-06-04 09:50:27.633546	36.8219
311	2	10	-1.29207	2025-06-04 09:50:33.638594	36.8219
312	2	1	-1.2841	2025-06-04 11:32:05.905169	36.8155
313	2	1	-1.29207	2025-06-13 17:59:15.259853	36.8219
314	2	1	-1.29207	2025-06-13 17:59:32.030718	36.8219
315	2	1	-1.29207	2025-06-13 18:12:25.131996	36.8219
316	2	1	43.6532	2025-06-13 18:12:30.504163	-79.3832
317	2	1	-1.29207	2025-06-13 18:12:43.09206	36.8219
318	2	1	-1.29207	2025-06-13 18:12:56.032546	36.8219
319	2	1	-1.29207	2025-06-13 18:13:09.029016	36.8219
320	2	1	-1.29207	2025-06-13 18:13:16.531892	36.8219
321	2	1	43.6532	2025-06-13 18:13:22.703877	-79.3832
322	2	1	-1.29207	2025-06-13 18:13:34.989324	36.8219
323	2	1	-1.29207	2025-06-13 18:14:01.020564	36.8219
324	2	1	-1.29207	2025-06-13 18:14:14.953807	36.8219
325	2	1	-1.29207	2025-06-13 18:14:28.067072	36.8219
326	2	1	43.6532	2025-06-13 18:14:42.500396	-79.3832
327	2	1	-1.29207	2025-06-13 18:14:55.188469	36.8219
328	2	1	-1.29207	2025-06-13 18:15:08.002635	36.8219
329	2	1	-1.29207	2025-06-13 18:15:20.943848	36.8219
330	2	1	-1.29207	2025-06-13 18:15:33.993421	36.8219
331	2	1	-1.29207	2025-06-13 18:15:48.003357	36.8219
332	2	1	-1.29207	2025-06-13 18:16:02.013289	36.8219
333	2	1	-1.29207	2025-06-13 18:16:13.986934	36.8219
334	2	1	-1.29207	2025-06-13 18:16:26.981251	36.8219
335	2	1	-1.29207	2025-06-13 18:16:41.551262	36.8219
336	2	1	43.6532	2025-06-13 18:16:55.527591	-79.3832
337	2	1	-1.29207	2025-06-13 18:17:09.022753	36.8219
338	2	1	-1.29207	2025-06-13 18:17:22.880579	36.8219
339	2	1	-1.29207	2025-06-13 18:17:34.997325	36.8219
340	2	1	-1.29207	2025-06-13 18:17:48.273664	36.8219
341	2	1	-1.29207	2025-06-13 18:18:02.098847	36.8219
342	2	1	-1.29207	2025-06-13 18:18:15.067894	36.8219
343	2	1	-1.29207	2025-06-13 18:18:22.145035	36.8219
344	2	1	-1.29207	2025-06-13 18:18:27.99862	36.8219
345	2	1	-1.29207	2025-06-13 18:18:41.962865	36.8219
346	2	1	-1.29207	2025-06-13 18:18:56.235526	36.8219
347	2	1	-1.29207	2025-06-13 18:19:10.310532	36.8219
348	2	1	-1.29207	2025-06-13 18:19:24.070845	36.8219
349	2	1	-1.29207	2025-06-13 18:19:37.996071	36.8219
350	2	1	-1.29207	2025-06-13 18:19:52.131077	36.8219
351	2	1	43.6532	2025-06-13 18:20:33.546416	-79.3832
352	2	1	-1.29207	2025-06-13 18:20:47.046885	36.8219
353	2	1	-1.29207	2025-06-13 18:21:00.993626	36.8219
354	2	1	-1.29207	2025-06-13 18:21:15.000334	36.8219
355	2	1	-1.29207	2025-06-13 18:21:28.228727	36.8219
356	2	1	-1.29207	2025-06-13 18:21:42.003617	36.8219
357	2	1	-1.29207	2025-06-13 18:21:54.975906	36.8219
358	2	1	-1.29207	2025-06-13 18:22:08.062334	36.8219
359	2	1	-1.29207	2025-06-13 18:22:34.524347	36.8219
360	2	1	-1.29207	2025-06-13 18:22:47.051287	36.8219
361	2	1	-1.29207	2025-06-13 18:23:00.026557	36.8219
362	2	1	-1.29207	2025-06-13 18:23:13.99939	36.8219
363	2	1	-1.29207	2025-06-13 18:23:26.986486	36.8219
364	2	1	-1.29207	2025-06-13 18:23:39.963798	36.8219
365	2	1	-1.29207	2025-06-13 18:23:49.537783	36.8219
366	2	1	-1.29207	2025-06-13 18:24:08.057541	36.8219
367	2	1	-1.29207	2025-06-13 18:24:21.52272	36.8219
368	2	1	-1.29207	2025-06-13 18:24:34.99086	36.8219
369	2	1	-1.29207	2025-06-13 18:24:48.002197	36.8219
370	2	1	-1.29207	2025-06-13 18:25:00.975086	36.8219
371	2	1	-1.29207	2025-06-13 18:25:27.506054	36.8219
372	2	1	-1.29207	2025-06-13 18:25:39.992129	36.8219
373	2	1	-1.29207	2025-06-13 18:25:52.98105	36.8219
374	2	1	-1.29207	2025-06-13 18:26:05.963052	36.8219
375	2	1	-1.29207	2025-06-13 18:26:19.993111	36.8219
376	2	1	43.6532	2025-06-13 18:26:34.458747	-79.3832
377	2	1	-1.29207	2025-06-13 18:26:48.022987	36.8219
378	2	1	-1.29207	2025-06-13 18:27:02.029531	36.8219
379	2	1	-1.29207	2025-06-13 18:27:14.986153	36.8219
380	2	1	-1.29207	2025-06-13 18:27:28.957351	36.8219
381	2	1	-1.29207	2025-06-13 18:27:43.013558	36.8219
382	2	1	-1.29207	2025-06-13 18:28:10.010961	36.8219
383	2	1	-1.29207	2025-06-13 18:28:24.017923	36.8219
384	2	1	-1.29207	2025-06-13 18:28:36.965561	36.8219
385	2	1	-1.29207	2025-06-13 18:28:50.435226	36.8219
386	2	1	-1.29207	2025-06-13 18:29:03.103333	36.8219
387	2	1	-1.29207	2025-06-13 18:29:16.353067	36.8219
388	2	1	-1.29207	2025-06-13 18:29:28.054106	36.8219
389	2	1	-1.29207	2025-06-13 18:29:42.985106	36.8219
390	2	1	-1.29207	2025-06-13 18:29:55.962169	36.8219
391	2	1	-1.29207	2025-06-13 18:30:22.965919	36.8219
392	2	1	-1.29207	2025-06-13 18:30:36.125059	36.8219
393	2	1	-1.29207	2025-06-13 18:30:48.945473	36.8219
394	2	1	-1.29207	2025-06-13 18:31:02.967822	36.8219
395	2	1	-1.29207	2025-06-13 18:31:15.958581	36.8219
396	2	1	-1.29207	2025-06-13 18:31:30.123146	36.8219
397	2	1	-1.29207	2025-06-13 18:31:44.265295	36.8219
398	2	1	-1.29207	2025-06-13 18:31:58.317805	36.8219
399	2	1	-1.29207	2025-06-13 18:32:11.131176	36.8219
400	2	1	-1.29207	2025-06-13 18:32:25.03049	36.8219
401	2	1	-1.29207	2025-06-13 18:32:38.003308	36.8219
402	2	1	43.6532	2025-06-13 18:32:51.631993	-79.3832
403	2	1	-1.29207	2025-06-13 18:33:04.969187	36.8219
404	2	1	-1.29207	2025-06-13 18:33:17.957062	36.8219
405	2	1	-1.29207	2025-06-13 18:33:30.951279	36.8219
406	2	1	-1.29207	2025-06-13 18:33:43.936094	36.8219
407	2	1	-1.29207	2025-06-13 18:33:57.93614	36.8219
408	2	1	-1.29207	2025-06-13 18:34:23.96448	36.8219
409	2	1	-1.29207	2025-06-13 18:34:38.118702	36.8219
410	2	1	-1.29207	2025-06-13 18:34:51.388072	36.8219
411	2	1	-1.29207	2025-06-13 18:35:05.052829	36.8219
412	2	1	-1.29207	2025-06-13 18:35:17.958868	36.8219
413	2	1	-1.29207	2025-06-13 18:35:31.964195	36.8219
414	2	1	-1.29207	2025-06-13 18:35:45.10652	36.8219
415	2	1	-1.29207	2025-06-13 18:36:13.561338	36.8219
416	2	1	-1.29207	2025-06-13 18:36:25.965166	36.8219
417	2	1	-1.29207	2025-06-13 18:36:38.970869	36.8219
418	2	1	-1.29207	2025-06-13 18:37:05.976183	36.8219
419	2	1	-1.29207	2025-06-13 18:37:18.9716	36.8219
420	2	1	-1.29207	2025-06-13 18:37:32.964224	36.8219
421	2	1	-1.29207	2025-06-13 18:37:45.975953	36.8219
422	2	1	-1.29207	2025-06-13 18:37:59.181727	36.8219
423	2	1	-1.29207	2025-06-13 18:38:11.955867	36.8219
424	2	1	-1.29207	2025-06-13 18:38:25.064377	36.8219
425	2	1	-1.29207	2025-06-13 18:38:37.973142	36.8219
426	2	1	-1.29207	2025-06-13 18:38:51.123502	36.8219
427	2	1	-1.29207	2025-06-13 18:39:04.059485	36.8219
428	2	1	-1.29207	2025-06-13 18:39:17.158551	36.8219
429	2	1	-1.29207	2025-06-13 18:39:30.043968	36.8219
430	2	1	-1.29207	2025-06-13 18:39:43.046196	36.8219
431	2	1	-1.29207	2025-06-13 18:40:10.980648	36.8219
432	2	1	-1.29207	2025-06-13 18:40:25.037448	36.8219
433	2	1	-1.29207	2025-06-13 18:40:37.977836	36.8219
434	2	1	-1.29207	2025-06-13 18:41:17.968498	36.8219
435	2	1	-1.29207	2025-06-13 18:41:31.983272	36.8219
436	2	1	-1.29207	2025-06-13 18:41:44.994746	36.8219
437	2	1	-1.29207	2025-06-13 18:42:13.065146	36.8219
438	2	1	-1.29207	2025-06-13 18:42:26.999494	36.8219
439	2	1	-1.29207	2025-06-13 18:42:40.347228	36.8219
440	2	1	-1.29207	2025-06-13 18:43:08.968869	36.8219
441	2	1	-1.29207	2025-06-13 18:43:22.932316	36.8219
442	2	1	-1.29207	2025-06-13 18:43:36.002501	36.8219
443	2	1	-1.29207	2025-06-13 18:43:48.977813	36.8219
444	2	1	-1.29207	2025-06-13 18:44:28.044748	36.8219
445	2	1	-1.29207	2025-06-13 18:44:41.956035	36.8219
446	2	1	-1.29207	2025-06-13 18:44:55.000794	36.8219
447	2	1	-1.29207	2025-06-13 18:45:08.965622	36.8219
448	2	1	-1.29207	2025-06-13 18:45:22.955896	36.8219
449	2	1	43.6532	2025-06-13 18:45:37.482303	-79.3832
450	2	1	-1.29207	2025-06-13 18:45:49.955604	36.8219
451	2	1	-1.29207	2025-06-13 18:46:02.966927	36.8219
452	2	1	-1.29207	2025-06-13 18:46:16.953795	36.8219
453	2	1	-1.29207	2025-06-13 18:46:43.990153	36.8219
454	2	1	-1.29207	2025-06-13 18:46:57.951406	36.8219
455	2	1	-1.29207	2025-06-13 18:47:39.968643	36.8219
456	2	1	-1.29207	2025-06-13 18:47:53.972961	36.8219
457	2	1	-1.29207	2025-06-13 18:48:20.939457	36.8219
458	2	1	-1.29207	2025-06-13 18:48:35.010759	36.8219
459	2	1	43.6532	2025-06-13 18:48:49.406076	-79.3832
460	2	1	-1.29207	2025-06-13 18:49:02.06501	36.8219
461	2	1	-1.29207	2025-06-13 18:49:28.966408	36.8219
462	2	1	-1.29207	2025-06-13 18:49:55.956088	36.8219
463	2	1	-1.29207	2025-06-13 18:50:09.993551	36.8219
464	2	1	-1.29207	2025-06-13 18:50:23.996048	36.8219
465	2	1	-1.29207	2025-06-13 18:50:37.999827	36.8219
466	2	1	-1.29207	2025-06-13 18:50:50.97614	36.8219
467	2	1	-1.29207	2025-06-13 18:51:05.053861	36.8219
468	2	1	-1.29207	2025-06-13 18:51:19.015273	36.8219
469	2	1	-1.29207	2025-06-13 18:51:32.978139	36.8219
470	2	1	-1.29207	2025-06-13 18:51:47.033804	36.8219
471	2	1	-1.29207	2025-06-13 18:52:00.949082	36.8219
472	2	1	-1.29207	2025-06-13 18:52:14.953991	36.8219
473	2	1	-1.29207	2025-06-13 18:52:28.989989	36.8219
474	2	1	-1.29207	2025-06-13 18:52:42.051186	36.8219
475	2	1	-1.29207	2025-06-13 18:52:54.987665	36.8219
476	2	1	-1.29207	2025-06-13 18:53:22.05952	36.8219
477	2	1	-1.29207	2025-06-13 18:53:35.001219	36.8219
478	2	1	-1.29207	2025-06-13 18:53:47.998025	36.8219
479	2	1	-1.29207	2025-06-13 18:54:00.967061	36.8219
480	2	1	-1.29207	2025-06-13 18:54:27.931841	36.8219
481	2	1	-1.29207	2025-06-13 18:54:40.977037	36.8219
482	2	1	-1.29207	2025-06-13 18:54:54.231307	36.8219
483	2	1	-1.29207	2025-06-13 18:55:19.968867	36.8219
484	2	1	-1.29207	2025-06-13 18:55:32.344507	36.8219
485	2	1	-1.29207	2025-06-13 18:56:00.93906	36.8219
486	2	1	-1.29207	2025-06-13 18:56:13.347745	36.8219
487	2	1	-1.29207	2025-06-13 18:56:26.364041	36.8219
488	2	1	-1.29207	2025-06-13 18:57:07.986735	36.8219
489	2	1	-1.29207	2025-06-13 18:57:21.9855	36.8219
490	2	1	-1.29207	2025-06-13 18:57:34.979991	36.8219
491	2	1	-1.29207	2025-06-13 18:57:49.867474	36.8219
492	2	1	-1.29207	2025-06-13 18:58:01.34781	36.8219
493	2	1	-1.29207	2025-06-13 18:59:22.015001	36.8219
494	2	1	-1.29207	2025-06-13 18:59:35.987536	36.8219
495	2	1	-1.29207	2025-06-13 18:59:49.259514	36.8219
496	2	1	-1.29207	2025-06-13 19:00:01.989588	36.8219
497	2	1	-1.29207	2025-06-13 19:00:14.953345	36.8219
498	2	1	-1.29207	2025-06-13 19:00:28.976025	36.8219
499	2	1	-1.29207	2025-06-13 19:00:41.97509	36.8219
500	2	1	-1.29207	2025-06-13 19:00:54.951139	36.8219
501	2	1	-1.29207	2025-06-13 19:01:07.993833	36.8219
502	2	1	-1.29207	2025-06-13 19:01:20.346453	36.8219
503	2	1	-1.29207	2025-06-13 19:01:33.982484	36.8219
504	2	1	-1.29207	2025-06-13 19:01:46.970428	36.8219
505	2	1	-1.29207	2025-06-13 19:02:00.037709	36.8219
506	2	1	-1.29207	2025-06-13 19:02:14.064339	36.8219
507	2	1	-1.29207	2025-06-13 19:02:39.960839	36.8219
508	2	1	-1.29207	2025-06-13 19:02:52.978947	36.8219
509	2	1	-1.29207	2025-06-13 19:03:06.984015	36.8219
510	2	1	-1.29207	2025-06-13 19:03:20.985343	36.8219
511	2	1	-1.29207	2025-06-13 19:03:35.000591	36.8219
512	2	1	-1.29207	2025-06-13 19:03:49.011797	36.8219
513	2	1	-1.29207	2025-06-13 19:04:02.971267	36.8219
514	2	1	-1.29207	2025-06-13 19:04:16.996041	36.8219
515	2	1	-1.29207	2025-06-13 19:04:30.982117	36.8219
516	2	1	-1.29207	2025-06-13 19:04:44.993406	36.8219
517	2	1	-1.29207	2025-06-13 19:04:58.97423	36.8219
518	2	1	-1.29207	2025-06-13 19:05:12.967874	36.8219
519	2	1	-1.29207	2025-06-13 19:05:26.97116	36.8219
520	2	1	-1.29207	2025-06-13 19:05:40.953395	36.8219
521	2	1	-1.29207	2025-06-13 19:06:06.964144	36.8219
522	2	1	-1.29207	2025-06-13 19:06:21.02301	36.8219
523	2	1	-1.29207	2025-06-13 19:06:33.958138	36.8219
524	2	1	-1.29207	2025-06-13 19:07:01.980607	36.8219
525	2	1	-1.29207	2025-06-13 19:07:16.025108	36.8219
526	2	1	-1.29207	2025-06-13 19:07:29.95393	36.8219
527	2	1	-1.29207	2025-06-13 19:07:42.945655	36.8219
528	2	1	-1.29207	2025-06-13 19:07:56.988856	36.8219
529	2	1	-1.29207	2025-06-13 19:08:10.958636	36.8219
530	2	1	-1.29207	2025-06-13 19:08:38.991828	36.8219
531	2	1	-1.29207	2025-06-13 19:08:52.956803	36.8219
532	2	1	-1.29207	2025-06-13 19:09:06.956758	36.8219
533	2	1	-1.29207	2025-06-13 19:09:19.973321	36.8219
534	2	1	-1.29207	2025-06-13 19:09:33.985826	36.8219
535	2	1	-1.29207	2025-06-13 19:09:46.973269	36.8219
536	2	1	-1.29207	2025-06-13 19:10:14.952435	36.8219
537	2	1	-1.29207	2025-06-13 19:10:28.988892	36.8219
538	2	1	-1.29207	2025-06-13 19:10:42.988874	36.8219
539	2	1	-1.29207	2025-06-13 19:10:56.166075	36.8219
540	2	1	-1.29207	2025-06-13 19:11:10.057106	36.8219
541	2	1	-1.29207	2025-06-13 19:11:23.94009	36.8219
542	2	1	-1.29207	2025-06-13 19:11:36.972107	36.8219
543	2	1	-1.29207	2025-06-13 19:11:50.97474	36.8219
544	2	1	-1.29207	2025-06-13 19:12:04.963867	36.8219
545	2	1	-1.29207	2025-06-13 19:12:17.945048	36.8219
546	2	1	-1.29207	2025-06-13 19:12:31.982868	36.8219
547	2	1	-1.29207	2025-06-13 19:12:45.170497	36.8219
548	2	1	-1.29207	2025-06-13 19:12:58.985905	36.8219
549	2	1	-1.29207	2025-06-13 19:13:13.0025	36.8219
550	2	1	-1.29207	2025-06-13 19:13:26.990292	36.8219
551	2	1	-1.29207	2025-06-13 19:13:40.947544	36.8219
552	2	1	-1.29207	2025-06-13 19:13:53.941451	36.8219
553	2	1	-1.29207	2025-06-13 19:14:06.98091	36.8219
554	2	1	-1.29207	2025-06-13 19:14:20.992368	36.8219
555	2	1	-1.29207	2025-06-13 19:15:01.976787	36.8219
556	2	1	-1.29207	2025-06-13 19:15:16.000242	36.8219
557	2	1	-1.29207	2025-06-13 19:15:43.979649	36.8219
558	2	1	-1.29207	2025-06-13 19:15:57.94166	36.8219
559	2	1	-1.29207	2025-06-13 19:16:11.946583	36.8219
560	2	1	-1.29207	2025-06-13 19:16:25.959815	36.8219
561	2	1	-1.29207	2025-06-13 19:16:52.989284	36.8219
562	2	1	-1.29207	2025-06-13 19:17:07.20111	36.8219
563	2	1	-1.29207	2025-06-13 19:17:21.070406	36.8219
564	2	1	-1.29207	2025-06-13 19:17:34.962321	36.8219
565	2	1	-1.29207	2025-06-13 19:17:48.988942	36.8219
566	2	1	-1.29207	2025-06-13 19:18:02.010843	36.8219
567	2	1	-1.29207	2025-06-13 19:18:15.938277	36.8219
568	2	1	-1.29207	2025-06-13 19:18:43.971914	36.8219
569	2	1	-1.29207	2025-06-13 19:18:57.97213	36.8219
570	2	1	-1.29207	2025-06-13 19:19:11.963417	36.8219
571	2	1	-1.29207	2025-06-13 19:19:25.981942	36.8219
572	2	1	-1.29207	2025-06-13 19:19:39.002606	36.8219
573	2	1	-1.29207	2025-06-13 19:19:51.977095	36.8219
574	2	1	-1.29207	2025-06-13 19:20:05.019022	36.8219
575	2	1	-1.29207	2025-06-13 19:20:31.952904	36.8219
576	2	1	-1.29207	2025-06-13 19:20:44.975717	36.8219
577	2	1	43.6532	2025-06-13 19:20:58.468789	-79.3832
578	2	1	-1.29207	2025-06-13 19:21:11.985646	36.8219
579	2	1	-1.29207	2025-06-13 19:21:26.028657	36.8219
580	2	1	-1.29207	2025-06-13 19:21:39.986783	36.8219
581	2	1	-1.29207	2025-06-13 19:21:53.032731	36.8219
582	2	1	-1.29207	2025-06-13 19:22:20.058315	36.8219
583	2	1	-1.29207	2025-06-13 19:22:34.003504	36.8219
584	2	1	-1.29207	2025-06-13 19:22:48.005928	36.8219
585	2	1	-1.29207	2025-06-13 19:23:15.043307	36.8219
586	2	1	-1.29207	2025-06-13 19:23:28.999092	36.8219
587	2	1	-1.29207	2025-06-13 19:23:42.991959	36.8219
588	2	1	-1.29207	2025-06-13 19:23:55.941433	36.8219
589	2	1	-1.29207	2025-06-13 19:24:09.964485	36.8219
590	2	1	-1.29207	2025-06-13 19:24:37.661122	36.8219
591	2	1	-1.29207	2025-06-13 19:24:50.985466	36.8219
592	2	1	-1.29207	2025-06-13 19:25:04.974619	36.8219
593	2	1	-1.29207	2025-06-13 19:25:17.988664	36.8219
594	2	1	-1.29207	2025-06-13 19:25:30.970443	36.8219
595	2	1	-1.29207	2025-06-13 19:25:58.025073	36.8219
596	2	1	-1.29207	2025-06-13 19:26:11.977726	36.8219
597	2	1	-1.29207	2025-06-13 19:26:25.932845	36.8219
598	2	1	-1.29207	2025-06-13 19:26:40.005979	36.8219
599	2	1	-1.29207	2025-06-13 19:26:52.933137	36.8219
600	2	1	-1.29207	2025-06-13 19:27:06.986007	36.8219
601	2	1	-1.29207	2025-06-13 19:27:19.988545	36.8219
602	2	1	-1.29207	2025-06-13 19:27:34.064753	36.8219
603	2	1	-1.29207	2025-06-13 19:27:59.957907	36.8219
604	2	1	-1.29207	2025-06-13 19:28:13.192081	36.8219
605	2	1	-1.29207	2025-06-13 19:28:25.95399	36.8219
606	2	1	-1.29207	2025-06-13 19:28:40.051778	36.8219
607	2	1	-1.29207	2025-06-13 19:28:53.979345	36.8219
608	2	1	-1.29207	2025-06-13 19:29:06.937292	36.8219
609	2	1	-1.29207	2025-06-13 19:29:21.03357	36.8219
610	2	1	-1.29207	2025-06-13 19:29:47.970284	36.8219
611	2	1	-1.29207	2025-06-13 19:30:01.984602	36.8219
612	2	1	-1.29207	2025-06-13 19:30:15.957019	36.8219
613	2	1	-1.29207	2025-06-13 19:30:43.939194	36.8219
614	2	1	-1.29207	2025-06-13 19:30:57.97573	36.8219
615	2	1	-1.29207	2025-06-13 19:31:11.963716	36.8219
616	2	1	-1.29207	2025-06-13 19:31:25.988108	36.8219
617	2	1	-1.29207	2025-06-13 19:31:39.949079	36.8219
618	2	1	-1.29207	2025-06-13 19:31:53.975315	36.8219
619	2	1	-1.29207	2025-06-13 19:32:07.344273	36.8219
620	2	1	43.6532	2025-06-13 19:32:36.821868	-79.3832
621	2	1	-1.29207	2025-06-13 19:32:49.983205	36.8219
622	2	1	-1.29207	2025-06-13 19:33:03.347931	36.8219
623	2	1	-1.29207	2025-06-13 19:33:30.945462	36.8219
624	2	1	-1.29207	2025-06-13 19:33:45.081198	36.8219
625	2	1	-1.29207	2025-06-13 19:33:57.95106	36.8219
626	2	1	43.6532	2025-06-13 19:34:12.565738	-79.3832
627	2	1	-1.29207	2025-06-13 19:34:25.976197	36.8219
628	2	1	43.6532	2025-06-13 19:34:39.347539	-79.3832
629	2	1	43.6532	2025-06-13 19:34:54.448	-79.3832
630	2	1	-1.29207	2025-06-13 19:35:06.351258	36.8219
631	2	1	-1.29207	2025-06-13 19:35:20.992436	36.8219
632	2	1	-1.29207	2025-06-13 19:35:33.968285	36.8219
633	2	1	-1.29207	2025-06-13 19:35:46.358251	36.8219
634	2	1	43.6532	2025-06-13 19:36:00.575563	-79.3832
635	2	1	-1.29207	2025-06-13 19:36:12.99595	36.8219
636	2	1	-1.29207	2025-06-13 19:36:25.957299	36.8219
637	2	1	-1.29207	2025-06-13 19:36:39.971046	36.8219
638	2	1	-1.29207	2025-06-13 19:36:53.941076	36.8219
639	2	1	-1.29207	2025-06-13 19:37:08.02774	36.8219
640	2	1	-1.29207	2025-06-13 19:37:20.992579	36.8219
641	2	1	-1.29207	2025-06-13 19:37:35.004799	36.8219
642	2	1	-1.29207	2025-06-13 19:37:47.34365	36.8219
643	2	1	-1.29207	2025-06-13 19:38:01.392339	36.8219
644	2	1	-1.29207	2025-06-13 19:38:14.226656	36.8219
645	2	1	-1.29207	2025-06-13 19:38:26.972629	36.8219
646	2	1	-1.29207	2025-06-13 19:38:39.962895	36.8219
647	2	1	-1.29207	2025-06-13 19:38:49.26995	36.8219
648	2	1	-1.29207	2025-06-13 19:39:22.06898	36.8219
649	2	1	-1.29207	2025-06-13 19:39:36.041095	36.8219
650	2	1	-1.29207	2025-06-13 19:39:49.343229	36.8219
651	2	1	-1.29207	2025-06-13 19:40:02.989994	36.8219
652	2	1	-1.29207	2025-06-13 19:40:16.345483	36.8219
653	2	1	-1.29207	2025-06-13 19:40:30.971349	36.8219
654	2	1	-1.29207	2025-06-13 19:40:44.951872	36.8219
655	2	1	-1.29207	2025-06-13 19:40:58.968509	36.8219
656	2	1	-1.29207	2025-06-13 19:41:12.956971	36.8219
657	2	1	-1.29207	2025-06-13 19:41:26.946858	36.8219
658	2	1	-1.29207	2025-06-13 19:41:39.971454	36.8219
659	2	1	-1.29207	2025-06-13 19:41:53.954364	36.8219
660	2	1	-1.29207	2025-06-13 19:42:06.993951	36.8219
661	2	1	-1.29207	2025-06-13 19:42:34.979758	36.8219
662	2	1	-1.29207	2025-06-13 19:43:01.957514	36.8219
663	2	1	-1.29207	2025-06-13 19:43:15.985254	36.8219
664	2	1	-1.29207	2025-06-13 19:43:29.986639	36.8219
665	2	1	-1.29207	2025-06-13 19:44:08.347319	36.8219
666	2	1	-1.29207	2025-06-13 19:45:02.994229	36.8219
667	2	1	-1.29207	2025-06-13 19:45:45.039924	36.8219
668	2	1	-1.29207	2025-06-13 19:45:58.997653	36.8219
669	2	1	-1.29207	2025-06-13 19:46:11.975646	36.8219
670	2	1	-1.29207	2025-06-13 19:46:37.943352	36.8219
671	2	1	-1.29207	2025-06-13 19:46:50.948109	36.8219
672	2	1	-1.29207	2025-06-13 19:47:04.098984	36.8219
673	2	1	-1.29207	2025-06-13 19:47:16.952621	36.8219
674	2	1	-1.29207	2025-06-13 19:47:30.993184	36.8219
675	2	1	-1.29207	2025-06-13 19:47:44.955748	36.8219
676	2	1	-1.29207	2025-06-13 19:47:57.949859	36.8219
677	2	1	-1.29207	2025-06-13 19:48:10.9781	36.8219
678	2	1	-1.29207	2025-06-13 19:48:24.002995	36.8219
679	2	1	-1.29207	2025-06-13 19:49:03.965549	36.8219
680	2	1	-1.29207	2025-06-13 19:49:16.992948	36.8219
681	2	1	-1.29207	2025-06-13 19:49:30.989783	36.8219
682	2	1	-1.29207	2025-06-13 19:49:44.963949	36.8219
683	2	1	-1.29207	2025-06-13 19:49:58.943596	36.8219
684	2	1	-1.29207	2025-06-13 19:50:25.973544	36.8219
685	2	1	-1.29207	2025-06-13 19:50:39.023889	36.8219
686	2	1	-1.29207	2025-06-13 19:50:52.993594	36.8219
687	2	1	-1.29207	2025-06-13 19:51:05.940397	36.8219
688	2	1	-1.29207	2025-06-13 19:51:18.976804	36.8219
689	2	1	-1.29207	2025-06-13 19:51:31.980617	36.8219
690	2	1	-1.29207	2025-06-13 19:51:44.964474	36.8219
691	2	1	-1.29207	2025-06-13 19:51:58.463071	36.8219
692	2	1	-1.29207	2025-06-13 19:52:52.95165	36.8219
693	2	1	-1.29207	2025-06-13 19:53:05.99322	36.8219
694	2	1	-1.29207	2025-06-13 19:53:19.029852	36.8219
695	2	1	-1.29207	2025-06-13 19:53:33.043218	36.8219
696	2	1	-1.29207	2025-06-13 19:53:46.995016	36.8219
697	2	1	-1.29207	2025-06-13 19:54:01.485527	36.8219
698	2	1	-1.29207	2025-06-13 19:54:14.989644	36.8219
699	2	1	-1.29207	2025-06-13 19:54:43.001369	36.8219
700	2	1	-1.29207	2025-06-13 19:54:57.021989	36.8219
701	2	1	-1.29207	2025-06-13 19:55:10.969629	36.8219
702	2	1	-1.29207	2025-06-13 19:55:24.989902	36.8219
703	2	1	-1.29207	2025-06-13 19:55:38.190195	36.8219
704	2	1	-1.29207	2025-06-13 19:55:52.234701	36.8219
705	2	1	-1.29207	2025-06-13 19:56:05.965827	36.8219
706	2	1	-1.29207	2025-06-13 19:56:20.001103	36.8219
707	2	1	-1.29207	2025-06-13 19:56:47.243087	36.8219
708	2	1	-1.29207	2025-06-13 19:56:59.966744	36.8219
709	2	1	-1.29207	2025-06-13 19:57:19.856759	36.8219
710	2	1	-1.29207	2025-06-13 19:57:26.069639	36.8219
711	2	1	-1.29207	2025-06-13 19:57:51.965165	36.8219
712	2	1	-1.29207	2025-06-13 19:58:05.978504	36.8219
713	2	1	-1.29207	2025-06-13 19:58:46.960747	36.8219
714	2	1	-1.29207	2025-06-13 19:59:00.965327	36.8219
715	2	1	-1.29207	2025-06-13 19:59:15.036734	36.8219
716	2	1	-1.29207	2025-06-13 19:59:27.979618	36.8219
717	2	1	-1.29207	2025-06-13 19:59:41.176746	36.8219
718	2	1	-1.29207	2025-06-13 19:59:53.973392	36.8219
719	2	1	-1.29207	2025-06-13 20:00:07.950154	36.8219
720	2	1	-1.29207	2025-06-13 20:00:21.952354	36.8219
721	2	1	-1.29207	2025-06-13 20:00:36.045665	36.8219
722	2	1	-1.29207	2025-06-13 20:00:50.246534	36.8219
723	2	1	-1.29207	2025-06-13 20:01:03.29437	36.8219
724	2	1	-1.29207	2025-06-13 20:01:15.939386	36.8219
725	2	1	-1.29207	2025-06-13 20:01:30.106049	36.8219
726	2	1	-1.29207	2025-06-13 20:01:43.34363	36.8219
727	2	1	-1.29207	2025-06-13 20:01:56.948413	36.8219
728	2	1	-1.29207	2025-06-13 20:02:09.978803	36.8219
729	2	1	-1.29207	2025-06-13 20:02:23.059397	36.8219
730	2	1	-1.29207	2025-06-13 20:02:36.013411	36.8219
731	2	1	-1.29207	2025-06-13 20:02:49.003008	36.8219
732	2	1	-1.29207	2025-06-13 20:03:01.996354	36.8219
733	2	1	-1.29207	2025-06-13 20:03:15.95523	36.8219
734	2	1	-1.29207	2025-06-13 20:03:43.991111	36.8219
735	2	1	-1.29207	2025-06-13 20:03:57.957659	36.8219
736	2	1	-1.29207	2025-06-13 20:04:10.986928	36.8219
737	2	1	-1.29207	2025-06-13 20:04:24.961712	36.8219
738	2	1	-1.29207	2025-06-13 20:04:37.957431	36.8219
739	2	1	-1.29207	2025-06-13 20:04:51.977786	36.8219
740	2	1	-1.29207	2025-06-13 20:05:05.953737	36.8219
741	2	1	-1.29207	2025-06-13 20:05:19.971377	36.8219
742	2	1	-1.29207	2025-06-13 20:05:33.97428	36.8219
743	2	1	43.6532	2025-06-13 20:05:47.480126	-79.3832
744	2	1	43.6532	2025-06-13 20:06:00.730495	-79.3832
745	2	1	-1.29207	2025-06-13 20:06:27.006263	36.8219
746	2	1	-1.29207	2025-06-13 20:06:42.121968	36.8219
747	2	1	-1.29207	2025-06-13 20:06:55.176042	36.8219
748	2	1	-1.29207	2025-06-13 20:07:22.282604	36.8219
749	2	1	-1.29207	2025-06-13 20:07:36.241655	36.8219
750	2	1	-1.29207	2025-06-13 20:07:51.872829	36.8219
751	2	1	-1.29207	2025-06-13 20:08:03.058398	36.8219
752	2	1	-1.29207	2025-06-13 20:08:17.383912	36.8219
753	2	1	43.6532	2025-06-13 20:08:30.833045	-79.3832
754	2	1	-1.29207	2025-06-13 20:08:43.949173	36.8219
755	2	1	-1.29207	2025-06-13 20:08:56.976392	36.8219
756	2	1	-1.29207	2025-06-13 20:09:10.946245	36.8219
757	2	1	-1.29207	2025-06-13 20:09:23.978983	36.8219
758	2	1	-1.29207	2025-06-13 20:09:50.981067	36.8219
759	2	1	-1.29207	2025-06-13 20:10:05.025555	36.8219
760	2	1	-1.29207	2025-06-13 20:10:18.073213	36.8219
761	2	1	-1.29207	2025-06-13 20:10:30.34528	36.8219
762	2	1	-1.29207	2025-06-13 20:10:57.976955	36.8219
763	2	1	-1.29207	2025-06-13 20:11:25.983965	36.8219
764	2	1	-1.29207	2025-06-13 20:11:39.010893	36.8219
765	2	1	-1.29207	2025-06-13 20:11:52.034562	36.8219
766	2	1	-1.29207	2025-06-13 20:12:06.206088	36.8219
767	2	1	-1.29207	2025-06-13 20:12:20.003587	36.8219
768	2	1	-1.29207	2025-06-13 20:12:46.977695	36.8219
769	2	1	-1.29207	2025-06-13 20:13:00.965786	36.8219
770	2	1	-1.29207	2025-06-13 20:13:13.969153	36.8219
771	2	1	-1.29207	2025-06-13 20:13:27.987692	36.8219
772	2	1	-1.29207	2025-06-13 20:13:53.981832	36.8219
773	2	1	-1.29207	2025-06-13 20:14:06.974428	36.8219
774	2	1	-1.29207	2025-06-13 20:14:20.974725	36.8219
775	2	1	43.6532	2025-06-13 20:14:35.441733	-79.3832
776	2	1	-1.29207	2025-06-13 20:14:48.972989	36.8219
777	2	1	-1.29207	2025-06-13 20:15:02.022058	36.8219
778	2	1	-1.29207	2025-06-13 20:15:14.980445	36.8219
779	2	1	-1.29207	2025-06-13 20:15:40.942217	36.8219
780	2	1	-1.29207	2025-06-13 20:15:54.983725	36.8219
781	2	1	-1.29207	2025-06-13 20:16:08.947057	36.8219
782	2	1	-1.29207	2025-06-13 20:16:21.997185	36.8219
783	2	1	43.6532	2025-06-13 20:16:35.485456	-79.3832
784	2	1	-1.29207	2025-06-13 20:17:01.982369	36.8219
785	2	1	-1.29207	2025-06-13 20:17:15.955399	36.8219
786	2	1	-1.29207	2025-06-13 20:17:28.983547	36.8219
787	2	1	-1.29207	2025-06-13 20:17:56.955029	36.8219
788	2	1	-1.29207	2025-06-13 20:18:10.96912	36.8219
789	2	1	-1.29207	2025-06-13 20:18:24.931127	36.8219
790	2	1	-1.29207	2025-06-13 20:18:37.98425	36.8219
791	2	1	-1.29207	2025-06-13 20:18:52.011182	36.8219
792	2	1	-1.29207	2025-06-13 20:19:05.04994	36.8219
793	2	1	-1.29207	2025-06-13 20:19:18.973325	36.8219
794	2	1	-1.29207	2025-06-13 20:19:32.973495	36.8219
795	2	1	-1.29207	2025-06-13 20:19:45.986934	36.8219
796	2	1	-1.29207	2025-06-13 20:19:59.934417	36.8219
797	2	1	-1.29207	2025-06-13 20:20:13.949019	36.8219
798	2	1	-1.29207	2025-06-13 20:20:27.978146	36.8219
799	2	1	-1.29207	2025-06-13 20:20:41.973776	36.8219
800	2	1	-1.29207	2025-06-13 20:20:55.991046	36.8219
801	2	1	-1.29207	2025-06-13 20:21:08.958783	36.8219
802	2	1	-1.29207	2025-06-13 20:21:22.972535	36.8219
803	2	1	-1.29207	2025-06-13 20:21:36.980274	36.8219
804	2	1	-1.29207	2025-06-13 20:21:50.950323	36.8219
805	2	1	-1.29207	2025-06-13 20:22:03.98339	36.8219
806	2	1	-1.29207	2025-06-13 20:22:16.97118	36.8219
807	2	1	-1.29207	2025-06-13 20:22:29.965347	36.8219
808	2	1	-1.29207	2025-06-13 20:22:55.95514	36.8219
809	2	1	-1.29207	2025-06-13 20:23:08.952588	36.8219
810	2	1	-1.29207	2025-06-13 20:23:36.031432	36.8219
811	2	1	-1.29207	2025-06-13 20:23:49.96764	36.8219
812	2	1	-1.29207	2025-06-13 20:24:03.998602	36.8219
813	2	1	-1.29207	2025-06-13 20:24:17.039879	36.8219
814	2	1	-1.29207	2025-06-13 20:24:31.039333	36.8219
815	2	1	-1.29207	2025-06-13 20:24:44.931711	36.8219
816	2	1	-1.29207	2025-06-13 20:25:11.979697	36.8219
817	2	1	-1.29207	2025-06-13 20:25:24.938514	36.8219
818	2	1	-1.29207	2025-06-13 20:25:38.175029	36.8219
819	2	1	-1.29207	2025-06-13 20:25:51.951756	36.8219
820	2	1	43.6532	2025-06-13 20:26:04.343735	-79.3832
821	2	1	-1.29207	2025-06-13 20:26:18.34624	36.8219
822	2	1	-1.29207	2025-06-13 20:26:32.985017	36.8219
823	2	1	-1.29207	2025-06-13 20:26:45.991376	36.8219
824	2	1	-1.29207	2025-06-13 20:26:58.964432	36.8219
825	2	1	-1.29207	2025-06-13 20:27:25.959039	36.8219
826	2	1	-1.29207	2025-06-13 20:27:38.945745	36.8219
827	2	1	-1.29207	2025-06-13 20:27:51.984615	36.8219
828	2	1	-1.29207	2025-06-13 20:28:17.975543	36.8219
829	2	1	-1.29207	2025-06-13 20:28:43.986238	36.8219
830	2	1	-1.29207	2025-06-13 20:28:57.994824	36.8219
831	2	1	-1.29207	2025-06-13 20:29:11.950491	36.8219
832	2	1	-1.29207	2025-06-13 20:29:25.952621	36.8219
833	2	1	-1.29207	2025-06-13 20:29:54.28459	36.8219
834	2	1	-1.29207	2025-06-13 20:30:06.982707	36.8219
835	2	1	-1.29207	2025-06-13 20:30:20.977506	36.8219
836	2	1	-1.29207	2025-06-13 20:30:33.986448	36.8219
837	2	1	-1.29207	2025-06-13 20:30:46.978535	36.8219
838	2	1	-1.29207	2025-06-13 20:31:12.961009	36.8219
839	2	1	-1.29207	2025-06-13 20:31:25.963679	36.8219
840	2	1	-1.29207	2025-06-13 20:32:17.993151	36.8219
841	2	1	-1.29207	2025-06-13 20:32:30.966986	36.8219
842	2	1	-1.29207	2025-06-13 20:32:43.954643	36.8219
843	2	1	-1.29207	2025-06-13 20:32:56.949285	36.8219
844	2	1	-1.29207	2025-06-13 20:33:22.98359	36.8219
845	2	1	-1.29207	2025-06-13 20:33:48.995218	36.8219
846	2	1	-1.29207	2025-06-13 20:34:02.950933	36.8219
847	2	1	-1.29207	2025-06-13 20:34:43.990734	36.8219
848	2	1	-1.29207	2025-06-13 20:35:12.189202	36.8219
849	2	1	-1.29207	2025-06-13 20:35:25.97822	36.8219
850	2	1	-1.29207	2025-06-13 20:35:38.957493	36.8219
851	2	1	-1.29207	2025-06-13 20:35:52.033016	36.8219
852	2	1	-1.29207	2025-06-13 20:36:05.98758	36.8219
853	2	1	-1.29207	2025-06-13 20:36:20.004455	36.8219
854	2	1	-1.29207	2025-06-13 20:36:33.227034	36.8219
855	2	1	-1.29207	2025-06-13 20:37:00.980461	36.8219
856	2	1	-1.29207	2025-06-13 20:37:13.986014	36.8219
857	2	1	-1.29207	2025-06-13 20:37:27.343085	36.8219
858	2	1	-1.29207	2025-06-13 20:37:41.981412	36.8219
859	2	1	-1.29207	2025-06-13 20:37:54.97154	36.8219
860	2	1	-1.29207	2025-06-13 20:38:08.991525	36.8219
861	2	1	-1.29207	2025-06-13 20:38:22.945264	36.8219
862	2	1	-1.29207	2025-06-13 20:38:35.961748	36.8219
863	2	1	-1.29207	2025-06-13 20:38:49.029435	36.8219
864	2	1	-1.29207	2025-06-13 20:39:01.994289	36.8219
865	2	1	-1.29207	2025-06-13 20:39:16.053153	36.8219
866	2	1	-1.29207	2025-06-13 20:39:43.058261	36.8219
867	2	1	-1.29207	2025-06-13 20:39:56.987809	36.8219
868	2	1	-1.29207	2025-06-13 20:40:23.003027	36.8219
869	2	1	43.6532	2025-06-13 20:40:37.471459	-79.3832
870	2	1	-1.29207	2025-06-13 20:40:50.345051	36.8219
871	2	1	-1.29207	2025-06-13 20:41:04.057465	36.8219
872	2	1	-1.29207	2025-06-13 20:41:18.050033	36.8219
873	2	1	-1.29207	2025-06-13 20:41:31.994637	36.8219
874	2	1	-1.29207	2025-06-13 20:41:58.992971	36.8219
875	2	1	-1.29207	2025-06-13 20:42:11.98906	36.8219
876	2	1	-1.29207	2025-06-13 20:42:26.241615	36.8219
877	2	1	-1.29207	2025-06-13 20:42:39.990502	36.8219
878	2	1	-1.29207	2025-06-13 20:42:52.952569	36.8219
879	2	1	-1.29207	2025-06-13 20:43:06.959339	36.8219
880	2	1	-1.29207	2025-06-13 20:43:19.981514	36.8219
881	2	1	-1.29207	2025-06-13 20:43:32.344581	36.8219
882	2	1	-1.29207	2025-06-13 20:43:59.984571	36.8219
883	2	1	-1.29207	2025-06-13 20:44:13.993219	36.8219
884	2	1	-1.29207	2025-06-13 20:44:26.344845	36.8219
885	2	1	-1.29207	2025-06-13 20:44:39.862504	36.8219
886	2	1	-1.29207	2025-06-13 20:44:53.93102	36.8219
887	2	1	-1.29207	2025-06-13 20:45:07.953339	36.8219
888	2	1	-1.29207	2025-06-13 20:45:22.421193	36.8219
889	2	1	-1.29207	2025-06-13 20:45:35.937763	36.8219
890	2	1	-1.29207	2025-06-13 20:45:48.963211	36.8219
891	2	1	-1.29207	2025-06-13 20:46:02.980974	36.8219
892	2	1	-1.29207	2025-06-13 20:46:15.973008	36.8219
893	2	1	-1.29207	2025-06-13 20:46:28.96975	36.8219
894	2	1	-1.29207	2025-06-13 20:46:42.037902	36.8219
895	2	1	-1.29207	2025-06-13 20:46:55.943836	36.8219
896	2	1	-1.29207	2025-06-13 20:47:09.981633	36.8219
897	2	1	-1.29207	2025-06-13 20:47:23.996553	36.8219
898	2	1	-1.29207	2025-06-13 20:47:37.979318	36.8219
899	2	1	-1.29207	2025-06-13 20:47:51.94912	36.8219
900	2	1	43.6532	2025-06-13 20:48:06.711445	-79.3832
901	2	1	-1.29207	2025-06-13 20:48:18.983832	36.8219
902	2	1	-1.29207	2025-06-13 20:48:33.040769	36.8219
903	2	1	-1.29207	2025-06-13 20:48:47.011805	36.8219
904	2	1	-1.29207	2025-06-13 20:49:00.96476	36.8219
905	2	1	-1.29207	2025-06-13 20:49:13.971543	36.8219
906	2	1	-1.29207	2025-06-13 20:49:27.228941	36.8219
907	2	1	-1.29207	2025-06-13 20:49:39.946251	36.8219
908	2	1	-1.29207	2025-06-13 20:49:53.962374	36.8219
909	2	1	-1.29207	2025-06-13 20:50:06.947245	36.8219
910	2	1	-1.29207	2025-06-13 20:50:19.344297	36.8219
911	2	1	-1.29207	2025-06-13 20:50:32.341799	36.8219
912	2	1	-1.29207	2025-06-13 20:50:46.018874	36.8219
913	2	1	-1.29207	2025-06-13 20:51:00.036368	36.8219
914	2	1	-1.29207	2025-06-13 20:51:12.967503	36.8219
915	2	1	-1.29207	2025-06-13 20:51:25.997594	36.8219
916	2	1	-1.29207	2025-06-13 20:51:39.964758	36.8219
917	2	1	-1.29207	2025-06-13 20:51:54.09892	36.8219
918	2	1	-1.29207	2025-06-13 20:52:07.197559	36.8219
919	2	1	-1.29207	2025-06-13 20:52:19.341472	36.8219
920	2	1	43.6532	2025-06-13 20:52:47.491091	-79.3832
921	2	1	-1.29207	2025-06-13 20:52:59.93273	36.8219
922	2	1	43.6532	2025-06-13 20:53:26.458759	-79.3832
923	2	1	-1.29207	2025-06-13 20:53:39.997913	36.8219
924	2	1	-1.29207	2025-06-13 20:53:53.952816	36.8219
925	2	1	-1.29207	2025-06-13 20:54:34.955958	36.8219
926	2	1	-1.29207	2025-06-13 20:54:48.959959	36.8219
927	2	1	-1.29207	2025-06-13 20:55:02.029132	36.8219
928	2	1	-1.29207	2025-06-13 20:55:15.030617	36.8219
929	2	1	-1.29207	2025-06-13 20:55:41.014329	36.8219
930	2	1	-1.29207	2025-06-13 20:55:54.01222	36.8219
931	2	1	-1.29207	2025-06-13 20:56:34.03629	36.8219
932	2	1	-1.29207	2025-06-13 20:56:46.965344	36.8219
933	2	1	-1.29207	2025-06-13 20:56:59.985953	36.8219
934	2	1	-1.29207	2025-06-13 20:57:12.994098	36.8219
935	2	1	-1.29207	2025-06-13 20:57:26.004601	36.8219
936	2	1	-1.29207	2025-06-13 20:57:38.976443	36.8219
937	2	1	-1.29207	2025-06-13 20:57:52.956277	36.8219
938	2	1	-1.29207	2025-06-13 20:58:19.047665	36.8219
939	2	1	-1.29207	2025-06-13 20:58:31.970234	36.8219
940	2	1	-1.29207	2025-06-13 20:58:44.964708	36.8219
941	2	1	-1.29207	2025-06-13 20:58:57.968926	36.8219
942	2	1	-1.29207	2025-06-13 20:59:37.022071	36.8219
943	2	1	-1.29207	2025-06-13 21:00:04.976824	36.8219
944	2	1	-1.29207	2025-06-13 21:00:18.010244	36.8219
945	2	1	-1.29207	2025-06-13 21:00:30.949074	36.8219
946	2	1	-1.29207	2025-06-13 21:00:45.008083	36.8219
947	2	1	-1.29207	2025-06-13 21:00:57.94302	36.8219
948	2	1	-1.29207	2025-06-13 21:01:11.978129	36.8219
949	2	1	-1.29207	2025-06-13 21:01:24.979622	36.8219
950	2	1	-1.29207	2025-06-13 21:01:39.005643	36.8219
951	2	1	-1.29207	2025-06-13 21:01:51.980907	36.8219
952	2	1	-1.29207	2025-06-13 21:02:04.964303	36.8219
953	2	1	-1.29207	2025-06-13 21:02:18.972695	36.8219
954	2	1	-1.29207	2025-06-13 21:02:45.941208	36.8219
955	2	1	-1.29207	2025-06-13 21:03:12.946481	36.8219
956	2	1	-1.29207	2025-06-13 21:03:25.89255	36.8219
957	2	1	-1.29207	2025-06-13 21:03:39.982372	36.8219
958	2	1	-1.29207	2025-06-13 21:04:07.010474	36.8219
959	2	1	-1.29207	2025-06-13 21:04:19.983882	36.8219
960	2	1	-1.29207	2025-06-13 21:04:32.903069	36.8219
961	2	0	-1.2841	2025-07-28 09:38:22.987619	36.8155
962	2	0	-1.2841	2025-07-28 09:38:37.783411	36.8155
963	2	0	-1.2841	2025-07-28 09:39:01.905363	36.8155
964	2	0	-1.2841	2025-07-28 09:41:06.724096	36.8155
965	2	0	-1.2841	2025-07-28 10:17:45.948728	36.8155
\.


--
-- Name: driver_shifts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.driver_shifts_id_seq', 1113, true);


--
-- Name: financials_financial_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.financials_financial_id_seq', 12168, true);


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.locations_id_seq', 2995, true);


--
-- Name: maintenance_maintenanceid_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.maintenance_maintenanceid_seq', 5, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.notifications_id_seq', 34, true);


--
-- Name: route_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.route_assignments_id_seq', 80, true);


--
-- Name: route_kpis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.route_kpis_id_seq', 38, true);


--
-- Name: route_time_patterns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.route_time_patterns_id_seq', 1, false);


--
-- Name: route_timetables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.route_timetables_id_seq', 5, true);


--
-- Name: routes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.routes_id_seq', 9, true);


--
-- Name: trip_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.trip_records_id_seq', 1, false);


--
-- Name: trips_trip_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.trips_trip_id_seq', 28197, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.users_id_seq', 31, true);


--
-- Name: vehicle_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.vehicle_assignments_id_seq', 30, true);


--
-- Name: vehicle_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.vehicle_history_id_seq', 965, true);


--
-- Name: vehicle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: olal
--

SELECT pg_catalog.setval('public.vehicle_id_seq', 43, true);


--
-- Name: driver_shifts driver_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.driver_shifts
    ADD CONSTRAINT driver_shifts_pkey PRIMARY KEY (id);


--
-- Name: financials financials_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.financials
    ADD CONSTRAINT financials_pkey PRIMARY KEY (financial_id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: maintenance maintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_pkey PRIMARY KEY (maintenanceid);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: route_assignments route_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_assignments
    ADD CONSTRAINT route_assignments_pkey PRIMARY KEY (id);


--
-- Name: route_kpis route_kpis_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_kpis
    ADD CONSTRAINT route_kpis_pkey PRIMARY KEY (id);


--
-- Name: route_time_patterns route_time_patterns_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_time_patterns
    ADD CONSTRAINT route_time_patterns_pkey PRIMARY KEY (id);


--
-- Name: route_timetables route_timetables_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_timetables
    ADD CONSTRAINT route_timetables_pkey PRIMARY KEY (id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: trip_records trip_records_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.trip_records
    ADD CONSTRAINT trip_records_pkey PRIMARY KEY (id);


--
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (trip_id);


--
-- Name: route_assignments unique_vehicle_date; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_assignments
    ADD CONSTRAINT unique_vehicle_date UNIQUE (vehicle_id, assignment_date);


--
-- Name: route_time_patterns unq_route_slot; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_time_patterns
    ADD CONSTRAINT unq_route_slot EXCLUDE USING gist (route_id WITH =, time_slot WITH &&);


--
-- Name: users users_driver_licence_key; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_driver_licence_key UNIQUE (driver_licence);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: vehicle_assignments vehicle_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.vehicle_assignments
    ADD CONSTRAINT vehicle_assignments_pkey PRIMARY KEY (id);


--
-- Name: vehicle_assignments vehicle_assignments_vehicle_id_start_date_key; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.vehicle_assignments
    ADD CONSTRAINT vehicle_assignments_vehicle_id_start_date_key UNIQUE (vehicle_id, start_date);


--
-- Name: vehicle_history vehicle_history_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.vehicle_history
    ADD CONSTRAINT vehicle_history_pkey PRIMARY KEY (id);


--
-- Name: vehicle vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (id);


--
-- Name: vehicle vehicle_plate_number_key; Type: CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.vehicle
    ADD CONSTRAINT vehicle_plate_number_key UNIQUE (plate_number);


--
-- Name: idx_driver_shifts_start_time; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_driver_shifts_start_time ON public.driver_shifts USING btree (start_time);


--
-- Name: idx_driver_shifts_status; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_driver_shifts_status ON public.driver_shifts USING btree (status);


--
-- Name: idx_driver_shifts_username; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_driver_shifts_username ON public.driver_shifts USING btree (driver_username);


--
-- Name: idx_notifications_created_at; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_notifications_created_at ON public.notifications USING btree (created_at);


--
-- Name: idx_notifications_read_at; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_notifications_read_at ON public.notifications USING btree (read_at);


--
-- Name: idx_notifications_username; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_notifications_username ON public.notifications USING btree (driver_username);


--
-- Name: idx_route_assignments_date; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_route_assignments_date ON public.route_assignments USING btree (assignment_date);


--
-- Name: idx_route_assignments_status; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_route_assignments_status ON public.route_assignments USING btree (status);


--
-- Name: idx_route_kpis_route_time; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_route_kpis_route_time ON public.route_kpis USING btree (route_id, metric_at DESC);


--
-- Name: idx_rtp_route_slot; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_rtp_route_slot ON public.route_time_patterns USING gist (route_id, time_slot);


--
-- Name: idx_trip_records_date; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_trip_records_date ON public.trip_records USING btree (trip_date);


--
-- Name: idx_trip_records_status; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_trip_records_status ON public.trip_records USING btree (status);


--
-- Name: idx_trip_records_username; Type: INDEX; Schema: public; Owner: olal
--

CREATE INDEX idx_trip_records_username ON public.trip_records USING btree (driver_username);


--
-- Name: financials financials_trip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.financials
    ADD CONSTRAINT financials_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(trip_id);


--
-- Name: notifications fk_notifications_driver; Type: FK CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_notifications_driver FOREIGN KEY (driver_username) REFERENCES public.users(username) ON DELETE CASCADE;


--
-- Name: maintenance maintenance_vehicleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.maintenance
    ADD CONSTRAINT maintenance_vehicleid_fkey FOREIGN KEY (vehicleid) REFERENCES public.vehicle(id);


--
-- Name: route_kpis route_kpis_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_kpis
    ADD CONSTRAINT route_kpis_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id) ON DELETE CASCADE;


--
-- Name: route_time_patterns route_time_patterns_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_time_patterns
    ADD CONSTRAINT route_time_patterns_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id) ON DELETE CASCADE;


--
-- Name: route_timetables route_timetables_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.route_timetables
    ADD CONSTRAINT route_timetables_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id);


--
-- Name: trips trips_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.users(id);


--
-- Name: trips trips_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(id);


--
-- Name: trips trips_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: olal
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicle(id);


--
-- PostgreSQL database dump complete
--

