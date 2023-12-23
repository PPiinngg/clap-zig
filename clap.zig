// Zig bindings for CLAP 1.1.10
// TODO: draft extensions

const clap = @This();

pub const Id = u32;
pub const INVALID_ID: clap.Id = 0xffffffff;

pub const String = [*:0]const u8;

pub const NAME_SIZE = 256;
pub const PATH_SIZE = 1024;
pub const Name = [NAME_SIZE]u8;
pub const Path = [PATH_SIZE]u8;

pub const BeatTime = i64;
pub const SecTime = i64;
pub const BEATTIME_FACTOR: BeatTime = 1 << 31;
pub const SECTIME_FACTOR: SecTime = 1 << 31;

pub const Version = extern struct {
    major: u32 = 1,
    minor: u32 = 1,
    revision: u32 = 10,

    pub fn isCompatible(self: clap.Version) callconv(.C) bool {
        return self.major >= 1;
    }
};

pub const Color = extern struct {
    alpha: u8,
    red: u8,
    green: u8,
    blue: u8,
};

pub const AudioBuffer = extern struct {
    data32: ?[*][*]f32,
    data64: ?[*][*]f64,
    channel_count: u32,
    latency: u32,
    constant_mask: u64,
};

pub const Process = extern struct {
    steady_time: i64,

    frames_count: u32,

    transport: *const clap.Event.Transport,

    audio_inputs: [*]const clap.AudioBuffer,
    audio_outputs: [*]clap.AudioBuffer,
    audio_inputs_count: u32,
    audio_outputs_count: u32,

    in_events: *const clap.Event.InputEvents,
    out_events: *const clap.Event.OutputEvents,

    pub const Status = enum(i32) {
        Error = 0,
        Continue = 1,
        Continue_If_Not_Quiet = 2,
        Tail = 3,
        Sleep = 4,
    };
};

pub const IStream = extern struct {
    ctx: *anyopaque,
    read: *const fn (stream: *const clap.IStream, buffer: *anyopaque, size: u64) callconv(.C) i64,
};

pub const OStream = extern struct {
    ctx: *anyopaque,
    write: *const fn (stream: *const clap.OStream, buffer: *anyopaque, size: u64) callconv(.C) i64,
};

pub const Event = extern struct {
    pub const CORE_EVENT_SPACE_ID: u16 = 0;

    pub const Header = extern struct {
        size: u32,
        time: u32,
        space: u16,
        event_type: clap.Event.Type,
        flags: u32,
    };

    pub const Flag = enum(u32) {
        Is_Live = 1 << 0,
        Dont_Record = 1 << 1,

        pub fn asInt(self: @This()) u32 {
            return @intFromEnum(self);
        }
    };

    pub const Type = enum(u16) {
        Note_On = 0,
        Note_Off = 1,
        Note_Choke = 2,
        Note_End = 3,

        Note_Expression = 4,

        Param_Value = 5,
        Param_Mod = 6,

        Param_Gesture_Begin = 7,
        Param_Gesture_End = 8,

        Transport = 9,
        Midi = 10,
        Midi_sysex = 11,
        Midi2 = 12,
    };

    pub const Note = extern struct {
        header: clap.Event.Header,

        note_id: i32,
        port_index: i16,
        channel: i16,
        key: i16,
        velocity: f64,
    };

    pub const NoteExpressionType = enum(i32) {
        Volume = 0,
        Pan = 1,
        Tuning = 2,
        Vibrato = 3,
        Expression = 4,
        Brightness = 5,
        Pressure = 6,
    };

    pub const NoteExpression = extern struct {
        header: clap.Event.Header,
        expression_id: clap.Event.NoteExpressionType,

        note_id: i32,
        port_index: i16,
        channel: i16,
        key: i16,

        value: f64,
    };

    pub const ParamValue = extern struct {
        header: clap.Event.Header,

        param_id: clap.Id,
        cookie: *anyopaque,

        note_id: i32,
        port_index: i16,
        channel: i16,
        key: i16,

        value: f64,
    };

    pub const ParamMod = extern struct {
        header: clap.Event.Header,

        param_id: clap.Id,
        cookie: ?*anyopaque,

        note_id: i32,
        port_index: i16,
        channel: i16,
        key: i16,

        amount: f64,
    };

    pub const ParamGesture = extern struct {
        header: clap.Event.Header,

        param_id: clap.Id,
    };

    pub const TransportFlags = enum(u32) {
        Has_Tempo = 1 << 0,
        Has_Beats_Timeline = 1 << 1,
        Has_Seconds_Timeline = 1 << 2,
        Has_Time_Signature = 1 << 3,
        Is_Playing = 1 << 4,
        Is_Recording = 1 << 5,
        Is_Loop_Active = 1 << 6,
        Is_Within_Pre_Roll = 1 << 7,
    };

    pub const Transport = extern struct {
        header: clap.Event.Header,

        flags: u32,

        song_pos_beats: BeatTime,
        song_pos_seconds: SecTime,

        tempo: f64,
        tempo_inc: f64,

        loop_start_beats: BeatTime,
        loop_end_beats: BeatTime,
        loop_start_seconds: SecTime,
        loop_end_seconds: SecTime,

        bar_start: BeatTime,
        bar_number: i32,

        tsig_num: u16,
        tsig_denom: u16,
    };

    pub const Midi = extern struct {
        header: clap.Event.Header,

        port_index: u16,
        data: [3]u8,
    };

    pub const MidiSysex = extern struct {
        header: clap.Event.Header,

        port_index: u16,
        buffer: String,
        size: u32,
    };

    pub const Midi2 = extern struct {
        header: clap.Event.Header,

        port_index: u16,
        data: [4]u32,
    };

    pub const InputEvents = extern struct {
        ctx: *anyopaque,

        size: *const fn (list: *const clap.Event.InputEvents) callconv(.C) u32,
        get: *const fn (list: *const clap.Event.InputEvents, index: u32) callconv(.C) *const clap.Event.Header,
    };

    pub const OutputEvents = extern struct {
        ctx: *anyopaque,

        try_push: *const fn (list: *const clap.Event.OutputEvents, event: *const Header) callconv(.C) bool,
    };
};

pub const Plugin = extern struct {
    descriptor: *const clap.Plugin.Descriptor,

    plugin_data: *anyopaque,

    init: *const fn (plugin: *const clap.Plugin) callconv(.C) bool,
    destroy: *const fn (plugin: *const clap.Plugin) callconv(.C) void,
    activate: *const fn (plugin: *const clap.Plugin, sample_rate: f64, min_frames_count: u32, max_frames_count: u32) callconv(.C) bool,
    deactivate: *const fn (plugin: *const clap.Plugin) callconv(.C) void,

    startProcessing: *const fn (plugin: *const clap.Plugin) callconv(.C) bool,
    stopProcessing: *const fn (plugin: *const clap.Plugin) callconv(.C) void,
    reset: *const fn (plugin: *const clap.Plugin) callconv(.C) void,

    process: *const fn (plugin: *const clap.Plugin, process: *const clap.Process) callconv(.C) clap.Process.Status,

    getExtension: *const fn (plugin: *const clap.Plugin, id: String) callconv(.C) ?*const anyopaque,
    onMainThread: *const fn (plugin: *const clap.Plugin) callconv(.C) void,

    pub const Descriptor = extern struct {
        clap_version: clap.Version = .{},

        id: String,
        name: String,
        vendor: ?String = "",
        url: ?String = "",
        manual_url: ?String = "",
        support_url: ?String = "",
        version: ?String = "",
        description: ?String = "",

        features: [*:null]const ?String,

        pub fn features(comptime feats: anytype) [*:null]const ?[*:0]const u8 {
            comptime var res: [feats.len:null]?[*:0]const u8 = undefined;
            inline for (feats, 0..) |f, i| {
                res[i] = switch (@typeInfo(@TypeOf(f))) {
                    .EnumLiteral => @field(clap.Plugin.Feature, @tagName(f)),
                    else => f,
                };
            }
            res[feats.len] = null;
            return &res;
        }
    };

    pub const Feature = extern struct {
        pub const instrument = "instrument";
        pub const audio_effect = "audio-effect";
        pub const note_effect = "note-effect";
        pub const note_detector = "note-detector";
        pub const analyzer = "analyzer";

        pub const synthesizer = "synthesizer";
        pub const sampler = "sampler";
        pub const drum = "drum";
        pub const drum_machine = "drum-machine";

        pub const filter = "filter";
        pub const phaser = "phaser";
        pub const equalizer = "equalizer";
        pub const de_esser = "de-esser";
        pub const phase_vocoder = "phase-vocoder";
        pub const frequency_shifter = "frequency-shifter";
        pub const pitch_shifter = "pitch-shifter";

        pub const distortion = "distortion";
        pub const transient_shaper = "transient-shaper";
        pub const compressor = "compressor";
        pub const expander = "expander";
        pub const gate = "gate";
        pub const limiter = "limiter";

        pub const flanger = "flanger";
        pub const chorus = "chorus";
        pub const delay = "delay";
        pub const reverb = "reverb";

        pub const tremolo = "tremolo";
        pub const glitch = "glitch";

        pub const utility = "utility";
        pub const pitch_correction = "pitch-correction";
        pub const restoration = "restoration";

        pub const multi_effects = "multi-effects";

        pub const mixing = "mixing";
        pub const mastering = "mastering";

        pub const mono = "mono";
        pub const stereo = "stereo";
        pub const surround = "surround";
        pub const ambisonic = "ambisonic";
    };

    pub const Entry = extern struct {
        clap_version: clap.Version = .{},
        init: *const fn (plugin_path: String) callconv(.C) bool,
        deinit: *const fn () callconv(.C) void,
        getFactory: *const fn (factory_id: String) callconv(.C) ?*const clap.Plugin.Factory,
    };

    pub const Factory = extern struct {
        get_plugin_count: *const fn (factory: *const clap.Plugin.Factory) callconv(.C) u32,
        get_plugin_descriptor: *const fn (factory: *const clap.Plugin.Factory, index: u32) callconv(.C) *const clap.Plugin.Descriptor,
        create_plugin: *const fn (factory: *const clap.Plugin.Factory, host: *const clap.Host, plugin_id: String) callconv(.C) ?*clap.Plugin,

        pub const ID: String = "clap.plugin-factory";
    };
};

pub const Host = extern struct {
    clap_version: clap.Version = .{},

    host_data: *anyopaque,

    name: String,
    vendor: String,
    url: String,
    version: String,

    get_extension: *const fn (host: *const clap.Host, extension_id: String) callconv(.C) ?*const anyopaque,
    request_restart: *const fn (host: *const clap.Host) callconv(.C) void,
    request_process: *const fn (host: *const clap.Host) callconv(.C) void,
    request_callback: *const fn (host: *const clap.Host) callconv(.C) void,
};

pub const ext = extern struct {
    pub const AudioPortsConfig = extern struct {
        id: clap.Id,
        name: clap.Name,

        input_port_count: u32,
        output_port_count: u32,

        has_main_input: bool,
        main_input_channel_count: u32,
        main_input_port_type: String,

        has_main_output: bool,
        main_output_channel_count: u32,
        main_output_port_type: String,

        pub const ID = "clap.audio-ports-config";

        pub const Plugin = extern struct {
            count: *const fn (plugin: *const clap.Plugin) callconv(.C) u32,
            get: *const fn (plugin: *const clap.Plugin, index: u32, config: *clap.ext.AudioPortsConfig) callconv(.C) bool,
            select: *const fn (plugin: *const clap.Plugin, config_id: clap.Id) callconv(.C) bool,
        };
        pub const Host = extern struct {
            rescan: *const fn (host: *const clap.Host) callconv(.C) void,
        };

        pub const Info = extern struct {
            pub const ID = "clap.audio-ports-config-info/draft-0";
            pub const Plugin = extern struct {
                current_config: *const fn (plugin: *const clap.Plugin) callconv(.C) clap.Id,
                get: *const fn (plugin: *const clap.Plugin, config_id: clap.Id, port_index: u32, is_input: bool, config: *clap.ext.AudioPorts.Info) callconv(.C) bool,
            };
        };
    };

    pub const AudioPorts = extern struct {
        pub const ID = "clap.audio-ports";

        pub const Flag = enum(u32) {
            Is_Main = 1 << 0,
            Supports_64bits = 1 << 1,
            Prefers_64bits = 1 << 2,
            Requires_Common_Sample_Size = 1 << 3,

            pub fn asInt(self: @This()) u32 {
                return @intFromEnum(self);
            }
        };

        pub const RescanFlag = enum(u32) {
            Names = 1 << 0,
            Flags = 1 << 1,
            Channel_Count = 1 << 2,
            Port_Type = 1 << 3,
            In_Place_Pair = 1 << 4,
            List = 1 << 5,

            pub fn asInt(self: @This()) u32 {
                return @intFromEnum(self);
            }
        };

        pub const Info = extern struct {
            id: clap.Id,
            name: clap.Name,

            flags: u32 = Flag.Requires_Common_Sample_Size.asInt(), // All flags except main
            channel_count: u32 = 2,

            port_type: String = PORT_STEREO,

            in_place_pair: clap.Id = clap.INVALID_ID,

            pub const PORT_STEREO = "stereo";
            pub const PORT_MONO = "mono";
        };

        pub const Plugin = extern struct {
            count: *const fn (plugin: *const clap.Plugin, is_input: bool) callconv(.C) u32,
            get: *const fn (plugin: *const clap.Plugin, index: u32, is_input: bool, info: *clap.ext.AudioPorts.Info) callconv(.C) bool,
        };
        pub const Host = extern struct {
            is_rescan_flag_supported: *const fn (host: *const clap.Host, flag: clap.ext.AudioPorts.RescanFlag) callconv(.C) bool,
            rescan: *const fn (host: *const clap.Host, flags: u32) callconv(.C) void,
        };
    };

    pub const EventRegistry = extern struct {
        pub const ID = "clap.event-registry";
        pub const Host = extern struct {
            query: *const fn (host: *const clap.Host, space_name: String, space_id: *u16) callconv(.C) bool,
        };
    };

    pub const Gui = extern struct {
        pub const ID = "clap.gui";

        pub const WindowApi = struct {
            pub const win32 = "win32";
            pub const cocoa = "cocoa";
            pub const x11 = "x11";
            pub const wayland = "wayland";
        };

        pub const Window = extern struct {
            api: String,
            handle: extern union {
                cocoa: *anyopaque,
                win32: *anyopaque,
                x11: c_ulong,
                ptr: *anyopaque,
            },
        };

        pub const ResizeHints = extern struct {
            can_resize_horizally: bool,
            can_resize_vertically: bool,
            preserve_aspect_ratio: bool,
            aspect_ratio_width: u32,
            aspect_ratio_height: u32,
        };

        pub const Plugin = extern struct {
            is_api_supported: *const fn (plugin: *const clap.Plugin, api: String, is_floating: bool) callconv(.C) bool,
            get_preferred_api: *const fn (plugin: *const clap.Plugin, api: String, is_floating: *bool) callconv(.C) bool,
            create: *const fn (plugin: *const clap.Plugin, api: String, is_floating: bool) callconv(.C) bool,
            destroy: *const fn (plugin: *const clap.Plugin) callconv(.C) void,
            set_scale: *const fn (plugin: *const clap.Plugin, scale: f32) callconv(.C) bool,
            get_size: *const fn (plugin: *const clap.Plugin, width: *u32, height: *u32) callconv(.C) bool,
            can_resize: *const fn (plugin: *const clap.Plugin) callconv(.C) bool,
            get_resize_hints: *const fn (plugin: *const clap.Plugin, hints: *clap.ext.Gui.ResizeHints) callconv(.C) bool,
            adjust_size: *const fn (plugin: *const clap.Plugin, width: *u32, height: *u32) callconv(.C) bool,
            set_size: *const fn (plugin: *const clap.Plugin, width: u32, height: u32) callconv(.C) bool,
            set_parent: *const fn (plugin: *const clap.Plugin, window: *const clap.ext.Gui.Window) callconv(.C) bool,
            set_transient: *const fn (plugin: *const clap.Plugin, window: *const clap.ext.Gui.Window) callconv(.C) bool,
            suggest_title: *const fn (plugin: *const clap.Plugin, title: String) callconv(.C) void,
            show: *const fn (plugin: *const clap.Plugin) callconv(.C) bool,
            hide: *const fn (plugin: *const clap.Plugin) callconv(.C) bool,
        };
        pub const Host = extern struct {
            resize_hints_changed: *const fn (host: *const clap.Host) callconv(.C) void,
            request_resize: *const fn (host: *const clap.Host, width: u32, height: u32) callconv(.C) bool,
            request_show: *const fn (host: *const clap.Host) callconv(.C) bool,
            request_hide: *const fn (host: *const clap.Host) callconv(.C) bool,
            closed: *const fn (host: *const clap.Host, was_destroyed: bool) callconv(.C) void,
        };
    };

    pub const Latency = extern struct {
        pub const ID = "clap.latency";

        pub const Plugin = extern struct {
            get: *const fn (plugin: *const clap.Plugin) callconv(.C) u32,
        };
        pub const Host = extern struct {
            changed: *const fn (host: *const clap.Host) callconv(.C) void,
        };
    };

    pub const Log = extern struct {
        pub const ID = "clap.log";

        pub const Severity = enum(i32) {
            Debug = 0,
            Info = 1,
            Warning = 2,
            Error = 3,
            Fatal = 4,
            Host_Misbehaving = 5,
            Plugin_Misbehaving = 6,
        };

        pub const Host = extern struct {
            log: *const fn (host: *const clap.Host, severity: clap.ext.Log.Severity, msg: String) callconv(.C) void,
        };
    };

    pub const NoteName = extern struct {
        name: clap.Name,
        port: i16,
        key: i16,
        channel: i16,

        pub const ID = "clap.note-name";

        pub const Plugin = extern struct {
            count: *const fn (plugin: *const clap.Plugin) callconv(.C) u32,
            get: *const fn (plugin: *const clap.Plugin, index: u32, note_name: *clap.ext.NoteName) callconv(.C) bool,
        };
        pub const Host = extern struct {
            changed: *const fn (host: *const clap.Host) callconv(.C) void,
        };
    };

    pub const NotePorts = extern struct {
        pub const ID = "clap.note-ports";

        pub const Dialect = enum(u32) {
            Clap = 1 << 0,
            Midi = 1 << 1,
            Midi_Mpe = 1 << 2,
            Midi2 = 1 << 3,
        };

        pub const RescanFlag = enum(u32) {
            All = 1 << 0,
            Names = 1 << 1,

            pub fn asInt(self: @This()) u32 {
                return @intFromEnum(self);
            }
        };

        pub const Info = extern struct {
            id: clap.Id,
            supported_dialects: clap.ext.NotePorts.Dialect,
            preferred_dialect: clap.ext.NotePorts.Dialect,
            name: clap.Name,
        };

        pub const Plugin = extern struct {
            count: *const fn (plugin: *const clap.Plugin, is_input: bool) callconv(.C) u32,
            get: *const fn (plugin: *const clap.Plugin, index: u32, is_input: bool, info: *clap.ext.NotePorts.Info) callconv(.C) bool,
        };
        pub const Host = extern struct {
            supported_dialects: *const fn (host: *const clap.Host) callconv(.C) u32,
            rescan: *const fn (host: *const clap.Host, flags: u32) callconv(.C) void,
        };
    };

    pub const Params = extern struct {
        pub const ID = "clap.params";

        pub const InfoFlag = enum(u32) {
            Is_Stepped = 1 << 0,
            Is_Periodic = 1 << 1,
            Is_Hidden = 1 << 2,
            Is_Readonly = 1 << 3,
            Is_Bypass = 1 << 4,
            Is_Automatable = 1 << 5,
            Is_Automatable_Per_Note_id = 1 << 6,
            Is_Automatable_Per_Key = 1 << 7,
            Is_Automatable_Per_Channel = 1 << 8,
            Is_Automatable_Per_Port = 1 << 9,
            Is_Modulatable = 1 << 10,
            Is_Modulatable_Per_Note_id = 1 << 11,
            Is_Modulatable_Per_Key = 1 << 12,
            Is_Modulatable_Per_Channel = 1 << 13,
            Is_Modulatable_Per_Port = 1 << 14,
            Requires_Process = 1 << 15,
            Is_Enum = 1 << 16,

            pub fn asInt(self: @This()) u32 {
                return @intFromEnum(self);
            }
        };

        pub const Info = extern struct {
            id: clap.Id,
            flags: u32,

            cookie: ?*anyopaque = null,

            name: clap.Name,
            path: clap.Path = helper.stringToPath(""),

            min_value: f64 = 0.0,
            max_value: f64 = 1.0,
            default_value: f64 = 0.0,
        };

        pub const RescanFlag = enum(u32) {
            Values = 1 << 0,
            Text = 1 << 1,
            Info = 1 << 2,
            All = 1 << 3,

            pub fn asInt(self: @This()) u32 {
                return @intFromEnum(self);
            }
        };

        pub const ClearFlag = enum(u32) {
            All = 1 << 0,
            Automations = 1 << 1,
            Modulations = 1 << 2,

            pub fn asInt(self: @This()) u32 {
                return @intFromEnum(self);
            }
        };

        pub const Plugin = extern struct {
            count: *const fn (plugin: *const clap.Plugin) callconv(.C) u32,

            get_info: *const fn (plugin: *const clap.Plugin, param_index: u32, param_info: *clap.ext.Params.Info) callconv(.C) bool,
            get_value: *const fn (plugin: *const clap.Plugin, param_id: clap.Id, out_value: *f64) callconv(.C) bool,

            value_to_text: *const fn (plugin: *const clap.Plugin, param_id: clap.Id, value: f64, out_buffer: [*:0]u8, out_buffer_capacity: u32) callconv(.C) bool,
            text_to_value: *const fn (plugin: *const clap.Plugin, param_id: clap.Id, param_value_text: [*:0]const u8, out_value: *f64) callconv(.C) bool,

            flush: *const fn (plugin: *const clap.Plugin, in: *const clap.Event.InputEvents, out: *const clap.Event.OutputEvents) callconv(.C) void,
        };
        pub const Host = extern struct {
            rescan: *const fn (host: *const clap.Host, flags: clap.ext.Params.RescanFlag) callconv(.C) void,
            clear: *const fn (host: *const clap.Host, param_id: clap.Id, flags: clap.ext.Params.ClearFlag) callconv(.C) void,
            request_flush: *const fn (host: *const clap.Host) callconv(.C) void,
        };
    };

    pub const PosixFdSupport = extern struct {
        pub const ID = "clap.posix-fd-support";

        pub const FdFlag = enum(u32) {
            Read = 1 << 0,
            Write = 1 << 1,
            Error = 1 << 2,

            pub fn asInt(self: @This()) u32 {
                return @intFromEnum(self);
            }
        };

        pub const Plugin = extern struct {
            on_fd: *const fn (plugin: *const clap.Plugin, fd: c_int, flags: clap.ext.PosixFdSupport.FdFlag) callconv(.C) void,
        };
        pub const Host = extern struct {
            register_fd: *const fn (host: *const clap.Host, fd: c_int, flags: clap.ext.PosixFdSupport.FdFlag) callconv(.C) bool,
            modify_fd: *const fn (host: *const clap.Host, fd: c_int, flags: clap.ext.PosixFdSupport.FdFlag) callconv(.C) bool,
            unregister_fd: *const fn (host: *const clap.Host, fd: c_int) callconv(.C) bool,
        };
    };

    pub const Render = extern struct {
        pub const ID = "clap.render";

        pub const Mode = enum(i32) {
            Realtime = 0,
            Offline = 1,
        };

        pub const Plugin = extern struct {
            has_hard_realtime_requirement: *const fn (plugin: *const clap.Plugin) callconv(.C) bool,
            set: *const fn (plugin: *const clap.Plugin, mode: clap.ext.Render.Mode) callconv(.C) bool,
        };
    };

    pub const State = extern struct {
        pub const ID = "clap.state";

        pub const Plugin = extern struct {
            save: *const fn (plugin: *const clap.Plugin, stream: *const clap.OStream) callconv(.C) bool,
            load: *const fn (plugin: *const clap.Plugin, stream: *const clap.IStream) callconv(.C) bool,
        };
        pub const Host = extern struct {
            mark_dirty: *const fn (host: *const clap.Host) callconv(.C) void,
        };
    };

    pub const Tail = extern struct {
        pub const ID = "clap.tail";

        pub const Plugin = extern struct {
            get: *const fn (plugin: *const clap.Plugin) callconv(.C) u32,
        };
        pub const Host = extern struct {
            changed: *const fn (host: *const clap.Host) callconv(.C) void,
        };
    };

    pub const ThreadCheck = extern struct {
        pub const ID = "clap.thread-check";
        pub const Host = extern struct {
            is_main_thread: *const fn (host: *const clap.Host) callconv(.C) bool,
            is_audio_thread: *const fn (host: *const clap.Host) callconv(.C) bool,
        };
    };

    pub const ThreadPool = extern struct {
        pub const ID = "clap.thread-pool";

        pub const Plugin = extern struct {
            exec: *const fn (plugin: *const clap.Plugin, task_index: u32) callconv(.C) void,
        };
        pub const Host = extern struct {
            request_exec: *const fn (host: *const clap.Host, num_tasks: u32) callconv(.C) bool,
        };
    };

    pub const TimerSupport = extern struct {
        pub const ID = "clap.timer-support";

        pub const Plugin = extern struct {
            on_timer: *const fn (plugin: *const clap.Plugin, timer_id: clap.Id) callconv(.C) void,
        };
        pub const Host = extern struct {
            register_timer: *const fn (host: *const clap.Host, period_ms: u32, timer_id: *clap.Id) callconv(.C) bool,
            unregister_timer: *const fn (host: *const clap.Host, timer_id: clap.Id) callconv(.C) bool,
        };
    };

    pub const VoiceInfo = extern struct {
        voice_count: u32,
        voice_capacity: u32,
        flags: u64,

        pub const ID = "clap.voice-info";

        pub const Plugin = extern struct {
            get: *const fn (plugin: *const clap.Plugin, info: *clap.ext.VoiceInfo) callconv(.C) bool,
        };
        pub const Host = extern struct {
            changed: *const fn (host: *const clap.Host) callconv(.C) void,
        };
    };
};

pub const helper = struct {
    pub const string = struct {
        pub fn toName(comptime str: [:0]const u8) clap.Name {
            return toSizedArray(clap.Name, str);
        }

        pub fn toPath(comptime str: [:0]const u8) clap.Path {
            return toSizedArray(clap.Path, str);
        }

        fn toSizedArray(comptime T: type, comptime str: [:0]const u8) T {
            comptime {
                var name: T = undefined;
                @memset(&name, 0);
                inline for (str, 0..str.len) |chr, i| {
                    name[i] = chr;
                }
                return name;
            }
        }
    };
};
