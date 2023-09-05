// See http://www.mpucoder.com/DVD/index.html

#include <std/io.pat>

#pragma endian big

// TODO Add enums for many constants

bitfield VersionNumber {
  padding : 8;
  major_version : 4;
  minor_version : 4;
} [[inline]];

/**
 * Note: Seems like char arrays can't be included in bitfields
 *       so some of the attributes structs are composed of inline
 *       bitfields.
 **/
namespace vts_menu {
  bitfield _AudioAttributes1 {
    coding_mode : 3;
    padding : 5;
    quantization : 2;
    sample_rate: 2;
    padding : 1;
    channels : 3 [[comment("channels - 1")]];
  } [[inline]];
  
  struct AudioAttributes {
    _AudioAttributes1 audio_attributes_1;
    padding[6];
  } [[static]];

  bitfield _SubpictureAttributes1 {
    coding_mode : 3;
    padding : 5;
  } [[inline]];

  struct SubpictureAttributes {
    _SubpictureAttributes1 subpicture_attributes_1;
    padding[5];
  } [[static]];
  
  bitfield _PGCCategory1 {
    bool entry_pgc : 1;
    padding : 3;
    menu_type : 4;
  } [[inline]];

  struct PGCCategory {
    _PGCCategory1;
    padding[1];
    u16 parental_management_mask;
  } [[static]];
}    

namespace vts_title {
  bitfield _AudioAttributes1 {
    coding_mode : 3;
    bool multichannel_extension_present : 1;
    language_type : 2;
    application_mode : 2;
    quantization : 2;
    sample_rate : 2;
    padding : 1;
    channels : 3 [[comment("channels - 1")]];
  } [[inline]];

  struct AudioAttributes {
    _AudioAttributes1 audio_attributes_1;
    char language_code[2];
    padding[4];
  } [[static]];

  bitfield _SubpictureAttributes1 {
    coding_mode : 3;
    padding : 3;
    language_type : 2;
    padding : 1;
  } [[inline]];
  
  struct SubpictureAttributes {
    _SubpictureAttributes1 subpicture_attributes_1;
    char language_code[2];
    padding[1];
    u8 code_extension;
  } [[static]];
  
  bitfield _PGCCategory1 {
    bool entry_pgc : 1;
    title_number : 7;
  } [[inline]];

  struct PGCCategory {
    _PGCCategory1;
    padding[1];
    u16 parental_management_mask;
  } [[static]];
}

bitfield _VideoAttributes1 {
  coding_mode : 2;
  standard : 2;
  aspect : 2;
  bool disallow_auto_pan_scan : 1;
  bool disallow_auto_letterbox : 1;
  
  cc_for_line_21 : 3;
  resolution : 1;
  padding : 1;
  film : 1;
} [[inline]];

struct VideoAttributes {
  _VideoAttributes1 video_attributes_1;
} [[static]];

struct VTS_PTT {
  u16 PGCN [[comment("ProGram ChaiN")]];
  u16 PGN [[comment("ProGram Number?")]];
} [[static]];

struct VTS_IFO_HEADER {
  char DVDVIDEO_VTS[12];
  u32 last_sector_of_title_set;
  padding[0xC];
  u32 last_sector_of_ifo;
  VersionNumber version_number;
  u32 vts_category;
  padding[0x5A];
  u32 end_byte_address_of_VTS_MAT;
  padding[0x3C];
  u32 start_sector_of_menu_vob;
  u32 start_sector_of_title_vob;
  u32 VTS_PTT_SRPT_sector;
  u32 VTS_PGCI_sector;
  u32 VTSM_PGCI_UT_sector;
  u32 VTS_TMAPTI_sector;
  u32 VTSM_C_ADT_sector;
  u32 VTSM_VOBU_ADMAP_sector;
  u32 VTS_C_ADT_sector;
  u32 VTS_VOBU_ADMAP_sector;
  padding[0x18];
  VideoAttributes vtsm_vobs_video_attributes;
  u16 vtsm_vobs_audio_streams_count;
  vts_menu::AudioAttributes vtsm_vobs_audio_attributes[vtsm_vobs_audio_streams_count];
  padding[0x50 - sizeof(vtsm_vobs_audio_attributes)];
  u16 vtsm_vobs_subpicture_count;
  vts_menu::SubpictureAttributes vtsm_vobs_subpicture_attributes[vtsm_vobs_subpicture_count];
  padding[0xAA - sizeof(vtsm_vobs_subpicture_attributes)];
  VideoAttributes vts_vobs_video_attributes;
  u16 vts_vobs_audio_streams_count;
  vts_title::AudioAttributes vts_vobs_audio_attributes[vts_vobs_audio_streams_count];
  padding[0x50 - sizeof(vts_vobs_audio_attributes)];
  u16 vts_vobs_subpicture_count;
  vts_title::SubpictureAttributes vts_vobs_subpicture_attributes[vts_vobs_subpicture_count];
  padding[0xC2 - sizeof(vts_vobs_subpicture_attributes)];
};

// PTT is Part-of-Title Table, i.e. Chapter Table.
// SRPT is maybe SeaRch (?) Table?
struct VTS_PTT_SRPT {
  u16 title_count;
  padding[2];
  u32 length;
  u32 ptt_offsets[title_count];
  VTS_PTT entries[while($ < addressof(this) + length)];
};


fn pgc_pointer_base(u16 offset) {
  return addressof(parent.parent);
};

bitfield _PGC_AST_CTL_1 {
  bool stream_available : 1;
  if (stream_available) {
    padding : 4;
    stream_number : 3;
  } else {
    padding : 7;
  }
} [[inline]];

struct PGC_AST_CTL {
  _PGC_AST_CTL_1;
  padding[1];
};

bitfield _PGC_SPST_CTL_1 {
  bool stream_available: 1;
  if (stream_available) {
    padding : 2;
    stream_number_4_3 : 5;
    padding : 3;
    stream_number_wide : 5;
    padding : 3;
    stream_number_letterbox : 5;
    padding : 3;
    stream_number_pan_scan : 5;
  } else {
    padding : 31;
  }
};

struct PGC_SPST_CTL {
  _PGC_SPST_CTL_1;
};

struct CLUT {
  u32 zero; // These values are not 0 but doc just says (0, Y, Cr, Cb)
  u32 Y;
  u32 Cr;
  u32 Cb;
};

// See http://www.mpucoder.com/DVD/vmi.html
struct Command {
  u8 command[8];
};

struct CommandTable {
  u16 pre_command_count;
  u16 post_command_count;
  u16 cell_command_count;
  u16 length; // Unused?
  Command pre_commands[pre_command_count];
  Command post_commands[post_command_count];
  Command cell_commands[cell_command_count];
};

struct ProgramMap {
  u8 entry_cell_number[parent.program_count];
};

bitfield _CellCategory1 {
  cell_type : 2;
  block_type : 2;
  bool seamless_multiplex : 1;
  bool interleaved : 1;
  bool scr_discontinuity : 1;
  bool seamless_angle_linked_in_dsi : 1;
  padding : 1;
  bool vobu_still_mode : 1;
  bool restricted : 1;
  application_cell_type : 5;
} [[inline]];

struct CellPlaybackInfo {
  _CellCategory1;
  u8 cell_still_time;
  u8 cell_command_number;
  u32 playback_time; // Binary Coded Decimal hh:mm:ss.ff with bytes 7&6 indicating framerate, 11 = 30 fps, 10 = illegal, 01 = 25 fps, 00 = illegal
  u32 first_vobu_start_sector;
  u32 first_ilvu_end_sector;
  u32 last_vobu_start_sector;
  u32 last_vobu_end_sector;
};

struct CellPlaybackTable {
  CellPlaybackInfo cell_playback_info[parent.cell_count];
};

struct CellPosition {
  u16 vob_id;
  padding[1];
  u8 cell_id;
};

struct CellPositionTable {
  CellPosition cell_positions[parent.cell_count];
};

struct PGC {
  padding[2];
  u8 program_count;
  u8 cell_count;
  u32 playback_time; // Binary Coded Decimal hh:mm:ss.ff with bytes 7&6 indicating framerate, 11 = 30 fps, 10 = illegal, 01 = 25 fps, 00 = illegal
  u32 prohibited_user_ops;
  PGC_AST_CTL audio_stream_control[8];
  PGC_SPST_CTL subpicture_stream_control[32];
  u16 next_pgcn;
  u16 prev_pgcn;
  u16 group_pgcn;
  u8 playback_mode;
  u8 still_time;
  CLUT color_lookup_table[4];
  u16 _commands [[no_unique_address, hidden]];
  if (_commands == 0x0) {
    padding[sizeof(u16)];
  } else {
    CommandTable *commands : u16 [[pointer_base("pgc_pointer_base")]];  
  }
  ProgramMap *program_map : u16 [[pointer_base("pgc_pointer_base")]];
  CellPlaybackTable *cell_playback_table : u16 [[pointer_base("pgc_pointer_base")]];
  CellPositionTable *cell_position_table : u16 [[pointer_base("pgc_pointer_base")]];
};

fn pgci_pointer_base(u32 offset) {
  return addressof(parent.parent.parent);
};

struct PGCInfo {
  vts_title::PGCCategory pgc_category;
  PGC *pgc_offset : u32 [[pointer_base("pgci_pointer_base")]];
};

struct VTS_PGCI {
  u16 program_chain_count;
  padding[2];
  u32 length;
  PGCInfo entries[program_chain_count];
};

fn vtsm_lu_pointer_base(u32 offset) {
  return addressof(parent.parent.parent);
};

struct VTSM_LU_INFO {
  vts_menu::PGCCategory pgc_category;
  PGC *pgc_offset : u32 [[pointer_base("pgci_pointer_base")]];
};

struct VTSM_LU {
  u16 program_chain_count;
  padding[2];
  u32 length; // Unused?
  VTSM_LU_INFO entries[program_chain_count];
};

struct VTSM_PGCI_UT_ENTRY {
  char language_code[2];
  padding[1];
  u8 menu_flags;
  VTSM_LU *vtsm_lu : u32 [[pointer_base("vtsm_lu_pointer_base")]];
};

struct VTSM_PGCI_UT {
  u16 language_unit_count;
  padding[2];
  u32 length; // Unused?
  VTSM_PGCI_UT_ENTRY entries[language_unit_count];
};

bitfield TMAP_OFFSET {
  bool new_cell : 1;
  offset : 31;
};

struct VTS_TMAP {
  u8 time_unit;
  padding[1];
  u16 entry_count;
  TMAP_OFFSET vobu_sector_offsets[entry_count];
};

fn vts_tmap_pointer_base(u32 offset) {
  return addressof(parent.parent.parent);
};

struct VTS_TMAP_ENTRY {
  VTS_TMAP *vts_tmap : u32 [[pointer_base("vts_tmap_pointer_base")]];
};

struct VTS_TMAPTI {
  u16 program_chain_count;
  padding[2];
  u32 length; // Unused?
  VTS_TMAP_ENTRY offsets[program_chain_count];
};

struct C_ADT_ENTRY {
  u16 vob_id;
  u8 cell_id;
  padding[1];
  u32 vob_start_sector;
  u32 vob_end_sector;
} [[static]];

// Cell ADdress Table?
struct C_ADT {
  u16 vob_count;
  padding[2];
  u32 length;
  C_ADT_ENTRY entries[while($ < addressof(this) + length)];
};

struct VOBU_ADMAP {
  u32 length;
  u32 vobu_sector_offsets[while($ < addressof(this) + length)]; // starting sector within VOB of first VOBU
};

/**
 * Returns absolute byte offset (address) for a given sector
 **/
fn sector_addr(u32 sector) {
  // DVD sectors are 2048 bytes and 0 indexed
  return sector * 2048;
};

struct VTS_IFO_FILE {
  VTS_IFO_HEADER header;
  VTS_PTT_SRPT vts_ptt_srpt @ sector_addr(header.VTS_PTT_SRPT_sector);
  VTS_PGCI vts_pgci @ sector_addr(header.VTS_PGCI_sector);
  VTSM_PGCI_UT vtsm_pgci_ut @ sector_addr(header.VTSM_PGCI_UT_sector);
  VTS_TMAPTI vts_tmapti @ sector_addr(header.VTS_TMAPTI_sector);
  C_ADT vtsm_c_adt @ sector_addr(header.VTSM_C_ADT_sector);
  VOBU_ADMAP vtsm_vobu_admap @ sector_addr(header.VTSM_VOBU_ADMAP_sector);
  C_ADT vts_c_adt @ sector_addr(header.VTS_C_ADT_sector);
  VOBU_ADMAP vts_vobu_admap @ sector_addr(header.VTS_VOBU_ADMAP_sector);
};

VTS_IFO_FILE ifo @ 0x00;

fn main() {
  for (u16 pgc_idx = 0, pgc_idx < ifo.vts_pgci.program_chain_count, pgc_idx = pgc_idx + 1) {
    std::print("--- PGC {} ---", pgc_idx);
    for (u8 cell_idx = 0, cell_idx < ifo.vts_pgci.entries[pgc_idx].pgc_offset.cell_count, cell_idx = cell_idx + 1) {
      std::print("VOB {}, Cell {}",
          ifo.vts_pgci.entries[pgc_idx].pgc_offset.cell_position_table.cell_positions[cell_idx].vob_id,
          ifo.vts_pgci.entries[pgc_idx].pgc_offset.cell_position_table.cell_positions[cell_idx].cell_id);
    }
  }
};

// Prints last parsed offset
//std::print("0x{:x}", $);