//
// Created by cmj on 2022/10/11.
//

#ifndef SAMI_CORE_SAMI_CORE_EFFECT_PARAM_H
#define SAMI_CORE_SAMI_CORE_EFFECT_PARAM_H

/*
 * the version about parameters is 14.0.1
 * */

/**
 * Name: "Gain"
 * Parameters:
 * +---------+-------------+-----------+-------------+------------+
 * | index   | name        | type      | range       | default    |
 * +---------+-------------+-----------+-------------+------------+
 * | 0       | "Gain dB"   | "Float"   | [-70, 35]   | 0          |
 * +---------+-------------+-----------+-------------+------------+
 */
enum ProcessorGainParameter {
    Gain_Gain_dB,
    Gain_Max = Gain_Gain_dB
};

/**
 * Name: "Compressor"
 * Parameters:
 * +---------+----------------------+-----------+-----------------+------------+
 *  | index   | name                 | type      | range           | default    |
 *  +---------+----------------------+-----------+-----------------+------------+
 *  | 0       | "Bypass"             | "Bool"    | [false, true]   | false      |
 *  +---------+----------------------+-----------+-----------------+------------+
 *  | 1       | "Ratio"              | "Float"   | [1, 40]         | 1          |
 *  +---------+----------------------+-----------+-----------------+------------+
 *  | 2       | "Threshold dB"       | "Float"   | [-70, 0]        | 0          |
 *  +---------+----------------------+-----------+-----------------+------------+
 *  | 3       | "Knee dB"            | "Float"   | [0, 70]         | 6          |
 *  +---------+----------------------+-----------+-----------------+------------+
 *  | 4       | "Attack"             | "Float"   | [0.005, 250]    | 0.25       |
 *  +---------+----------------------+-----------+-----------------+------------+
 *  | 5       | "Release"            | "Float"   | [1, 2500]       | 100        |
 *  +---------+----------------------+-----------+-----------------+------------+
 *  | 6       | "Auto Makeup Gain"   | "Bool"    | [false, true]   | true       |
 *  +---------+----------------------+-----------+-----------------+------------+
 *  | 7       | "Output Gain dB"     | "Float"   | [-35, 35]       | 0          |
 *  +---------+----------------------+-----------+-----------------+------------+
 *  | 8       | "Lookahead"          | "Float"   | [0, 10]         | 0          |
 *  +---------+----------------------+-----------+-----------------+------------+
 */
enum ProcessorCompressorParameter {
    Compressor_Bypass,
    Compressor_Ratio,
    Compressor_Threshold_dB,
    Compressor_Knee_dB,
    Compressor_Attack,
    Compressor_Release,
    Compressor_Auto_Makeup_Gain,
    Compressor_Output_Gain_dB,
    Compressor_Lookahead,
    Compressor_Max = Compressor_Lookahead
};

/**
 * Name: "Chorus"
 * Parameters:
 * +---------+-------------------------+-----------+-----------------+------------+
 * | index   | name                    | type      | range           | default    |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 0       | "Bypass"                | "Bool"    | [false, true]   | false      |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 1       | "Delay"                 | "Float"   | [0.5, 20]       | 4          |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 2       | "Rate"                  | "Float"   | [0, 4]          | 1          |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 3       | "Depth"                 | "Float"   | [0, 5]          | 2          |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 4       | "Stereo Phase Offset"   | "Float"   | [0, 1]          | 1          |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 5       | "Feedback"              | "Float"   | [0, 0.96]       | 0          |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 6       | "Wetness"               | "Float"   | [0, 1]          | 1          |
 * +---------+-------------------------+-----------+-----------------+------------+
 */
enum ProcessorChorusParameter {
    Chorus_Bypass,
    Chorus_Delay,
    Chorus_Rate,
    Chorus_Depth,
    Chorus_Stereo_Phase_Offset,
    Chorus_Feedback,
    Chorus_Wetness,
    Chorus_Max = Chorus_Wetness
};

/**
 * Name: "Distortion"
 * Parameters:
 * +---------+--------------------------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
 * | index   | name                     | type       | range | default    |
 * +---------+--------------------------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
 * | 0       | "Bypass"                 | "Bool"     | [false, true] | false      |
 * +---------+--------------------------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
 * | 1       | "Distortion Mode"        | "Choice"   | ["Cubic", "Tanh", "Arctan", "ArctanTanh", "L1", "L2",
 * "HardClip", "DeadZone", "FoldBackTriangle", "FoldBackSine", "FoldBackSinArctan", "BitCrush", "Decimate"]   |
 * "Cubic"    |
 * +---------+--------------------------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
 * | 2       | "Distortion Amount"      | "Float"    | [0, 1] | 0          |
 * +---------+--------------------------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
 * | 3       | "Apply Upsampling"       | "Choice"   | ["None", "X8", "X16", "X32"] | "None"     |
 * +---------+--------------------------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
 * | 4       | "Wetness"                | "Float"    | [0, 1] | 1          |
 * +---------+--------------------------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
 * | 5       | "Post Distortion Gain"   | "Float"    | [-40, 0] | 0          |
 * +---------+--------------------------+------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------+
 */
enum ProcessorDistortionParameter {
    Distortion_Bypass,
    Distortion_Distortion_Mode,
    Distortion_Distortion_Amount,
    Distortion_Apply_Upsampling,
    Distortion_Wetness,
    Distortion_Post_Distortion_Gain,
    Distortion_Max = Distortion_Post_Distortion_Gain,
};

/**
 * Name: "Echo"
 * Parameters:
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | index  | name                         | type      | range                                                                 | default                |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 0      | "Dry Bypass"                 | "Bool"    | [false, true]                                                         | false                  |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 1      | "Dry Gain dB"                | "Float"   | [-35.0, 6.0]                                                          | 0.0                    |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 2      | "Dry Pan"                    | "Float"   | [-1.0, 1.0]                                                           | 0.0                    |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 3      | "Tap 1 Bypass"               | "Bool"    | [false, true]                                                         | false                  |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * |        |                              |           | ["32nd Note Triplet", "32nd Note", "32nd Note Dotted",                |                        |
 * |        |                              |           | "16th Note Triplet", "16th Note", "16th Note Dotted",                 |                        |
 * | 4      | "Tap 1 Delay Time Synced"    | "Choice"  | "8th Note Triplet", "8th Note", "8th Note Dotted",                    | "Quarter Note"         |
 * |        |                              |           | "Quarter Note Triplet", "Quarter Note", "Quarter Note Dotted",        |                        |
 * |        |                              |           |  "Half Note Triplet", "Half Note", "Half Note Dotted", "Whole Note"]  |                        |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 5      | "Tap 1 Delay Time Unsynced"  | "Float"   | [0.005000000353902578, 5.0]                                           | 0.005000000353902578   |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 6      | "Tap 1 Feedback"             | "Float"   | [0.0, 1.0]                                                            | 0.4000000059604645     |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 7      | "Tap 1 Gain dB"              | "Float"   | [-35.0, 6.0]                                                          | -15.0                  |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 8      | "Tap 1 Pan"                  | "Float"   | [-1.0, 1.0]                                                           | -1.0                   |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 9      | "Tap 1 Sync"                 | "Bool"    | [false, true]                                                         | true                   |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 10     | "Tap 2 Bypass"               | "Bool"    | [false, true]                                                         | false                  |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * |        |                              |           | ["32nd Note Triplet", "32nd Note", "32nd Note Dotted",                |                        |
 * |        |                              |           | "16th Note Triplet", "16th Note", "16th Note Dotted",                 |                        |
 * | 11     | "Tap 2 Delay Time Synced"    | "Choice"  | "8th Note Triplet", "8th Note", "8th Note Dotted",                    | "8th Note Dotted"      |
 * |        |                              |           | "Quarter Note Triplet", "Quarter Note", "Quarter Note Dotted",        |                        |
 * |        |                              |           |  "Half Note Triplet", "Half Note", "Half Note Dotted", "Whole Note"]  |                        |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 12     | "Tap 2 Delay Time Unsynced"  | "Float"   | [0.005000000353902578, 5.0]                                           | 0.005000000353902578   |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 13     | "Tap 2 Feedback"             | "Float"   | [0.0, 1.0]                                                            | 0.4000000059604645     |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 14     | "Tap 2 Gain dB"              | "Float"   | [-35.0, 6.0]                                                          | -15.0                  |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 15     | "Tap 2 Pan"                  | "Float"   | [-1.0, 1.0]                                                           | 1.0                    |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 16     | "Tap 2 Sync"                 | "Bool"    | [false, true]                                                         | true                   |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 17     | "HPF Is Active"              | "Bool"    | [false, true]                                                         | false                  |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 18     | "HPF Frequency"              | "Float"   | [20.0, 20000.0]                                                       | 20.0                   |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 19     | "HPF Resonance"              | "Float"   | [0.10000000149011612, 20.0]                                           | 1.0                    |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 20     | "LPF Is Active"              | "Bool"    | [false, true]                                                         | false                  |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 21     | "LPF Frequency"              | "Float"   | [20.0, 20000.0]                                                       | 20000.0                |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 * | 22     | "LPF Resonance"              | "Float"   | [0.10000000149011612, 20.0]                                           | 1.0                    |
 * +--------+------------------------------+-----------+-----------------------------------------------------------------------+------------------------+
 */
enum ProcessorEchoParameter {
    Echo_Dry_Bypass,
    Echo_Dry_Gain_dB,
    Echo_Dry_Pan,
    Echo_Tap_1_Bypass,
    Echo_Tap_1_Delay_Time_Synced,
    Echo_Tap_1_Delay_Time_Unsynced,
    Echo_Tap_1_Feedback,
    Echo_Tap_1_Gain_dB,
    Echo_Tap_1_Pan,
    Echo_Tap_1_Sync,
    Echo_Tap_2_Bypass,
    Echo_Tap_2_Delay_Time_Synced,
    Echo_Tap_2_Delay_Time_Unsynced,
    Echo_Tap_2_Feedback,
    Echo_Tap_2_Gain_dB,
    Echo_Tap_2_Pan,
    Echo_Tap_2_Sync,
    Echo_HPF_Is_Active,
    Echo_HPF_Frequency,
    Echo_HPF_Resonance,
    Echo_LPF_Is_Active,
    Echo_LPF_Frequency,
    Echo_LPF_Resonance,
    Echo_Max = Echo_LPF_Resonance,
};

/**
 * Name: "Filter"
 * Parameters:
 * +---------+-----------------+------------+---------------------------------------------------------------------------------------------------------------------------+--------------+
 * | index   | name            | type       | range | default      |
 * +---------+-----------------+------------+---------------------------------------------------------------------------------------------------------------------------+--------------+
 * | 0       | "Filter Mode"   | "Choice"   | ["LowPass", "HighPass", "BandPass", "NormalisedBandPass", "Bell",
 * "HighShelf", "LowShelf", "AllPass", "Notch", "Morph"]   | "LowPass"    |
 * +---------+-----------------+------------+---------------------------------------------------------------------------------------------------------------------------+--------------+
 * | 1       | "Cutoff Freq"   | "Float"    | [20, 20000] | 1000         |
 * +---------+-----------------+------------+---------------------------------------------------------------------------------------------------------------------------+--------------+
 * | 2       | "Resonance"     | "Float"    | [0.1, 20] | 1            |
 * +---------+-----------------+------------+---------------------------------------------------------------------------------------------------------------------------+--------------+
 * | 3       | "Gain dB"       | "Float"    | [-20, 20] | 0            |
 * +---------+-----------------+------------+---------------------------------------------------------------------------------------------------------------------------+--------------+
 * | 4       | "Morph"         | "Float"    | [-1, 1] | 0            |
 * +---------+-----------------+------------+---------------------------------------------------------------------------------------------------------------------------+--------------+
 */
enum ProcessorFilterParameter {
    Filter_Filter_Mode,
    Filter_Cutoff_Freq,
    Filter_Resonance,
    Filter_Gain_dB,
    Filter_Morph,
    Filter_Max = Filter_Morph,
};

/**
 * Name: "GainAndPan"
 * Parameters:
 * +---------+-------------+-----------+-------------+------------+
 * | index   | name        | type      | range       | default    |
 * +---------+-------------+-----------+-------------+------------+
 * | 0       | "Gain dB"   | "Float"   | [-70, 35]   | 0          |
 * +---------+-------------+-----------+-------------+------------+
 * | 1       | "Pan"       | "Float"   | [-1, 1]     | 0          |
 * +---------+-------------+-----------+-------------+------------+
 */
enum ProcessorGainAndPanParameter {
    GainAndPan_Gain_dB,
    GainAndPan_Pan,
    GainAndPan_Max = GainAndPan_Pan,
};

/**
 * Name: "Limiter"
 * Parameters:
 * +---------+-------------------------+-----------+-----------------+------------+
 * | index   | name                    | type      | range           | default    |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 0       | "Bypass"                | "Bool"    | [false, true]   | false      |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 1       | "Input Gain dB"         | "Float"   | [0, 24]         | 0          |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 2       | "Ceiling dB"            | "Float"   | [-24, 0]        | -0.3       |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 3       | "Release"               | "Float"   | [1, 3000]       | 500        |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 4       | "Lookahead"             | "Float"   | [0, 10]         | 0          |
 * +---------+-------------------------+-----------+-----------------+------------+
 * | 5       | "Audition Unity Gain"   | "Bool"    | [false, true]   | false      |
 * +---------+-------------------------+-----------+-----------------+------------+
 */
enum ProcessorLimiterParameter {
    Limiter_Bypass,
    Limiter_Input_Gain_dB,
    Limiter_Ceiling_dB,
    Limiter_Release,
    Limiter_Lookahead,
    Limiter_Audition_Unity_Gain,
    Limiter_Max = Limiter_Audition_Unity_Gain,
};

/**
  * Name: "Reverb"
  * Parameters:
  * +---------+----------------------+-----------+-----------------+------------+
  * | index   | name                 | type      | range           | default    |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 0       | "Bypass"             | "Bool"    | [false, true]   | false      |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 1       | "Decay Time"         | "Float"   | [0.5, 16]       | 3          |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 2       | "Damp"               | "Float"   | [0, 1]          | 0.5        |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 3       | "Mod Depth"          | "Float"   | [0, 1]          | 0          |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 4       | "Mod Rate"           | "Float"   | [0.01, 7.5]     | 0          |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 5       | "Wet Gain"           | "Float"   | [-36, 12]       | 0          |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 6       | "Wet Stereo Width"   | "Float"   | [0, 2]          | 1          |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 7       | "Wet Mix"            | "Float"   | [0, 1]          | 0.5        |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 8       | "Wet LP Bypass"      | "Bool"    | [false, true]   | true       |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 9       | "Wet HP Bypass"      | "Bool"    | [false, true]   | true       |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 10      | "Wet LP Freq"        | "Float"   | [20, 20000]     | 20000      |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 11      | "Wet HP Freq"        | "Float"   | [20, 20000]     | 20         |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 12      | "Wet LP Res"         | "Float"   | [0.1, 20]       | 1          |
  * +---------+----------------------+-----------+-----------------+------------+
  * | 13      | "Wet HP Res"         | "Float"   | [0.1, 20]       | 1          |
  * +---------+----------------------+-----------+-----------------+------------+
  */

enum ProcessorReverbParameter {
    Reverb_Bypass,
    Reverb_Decay_Time,
    Reverb_Damp,
    Reverb_Mod_Depth,
    Reverb_Mod_Rate,
    Reverb_Wet_Gain,
    Reverb_Wet_Stereo_Width,
    Reverb_Wet_Mix,
    Reverb_Wet_LP_Bypass,
    Reverb_Wet_HP_Bypass,
    Reverb_Wet_LP_Freq,
    Reverb_Wet_HP_Freq,
    Reverb_Wet_LP_Res,
    Reverb_Wet_HP_Res,
    Reverb_Max = Reverb_Wet_HP_Res,
};

/**
 * Name: "Vibrato"
 * Parameters:
 * +---------+--------------------+-----------+-----------------+------------+
 * | index   | name               | type      | range           | default    |
 * +---------+--------------------+-----------+-----------------+------------+
 * | 0       | "Bypass"           | "Bool"    | [false, true]   | false      |
 * +---------+--------------------+-----------+-----------------+------------+
 * | 1       | "Rate Hz"          | "Float"   | [1, 8]          | 4          |
 * +---------+--------------------+-----------+-----------------+------------+
 * | 2       | "Depth Semitone"   | "Float"   | [0, 2]          | 0.5        |
 * +---------+--------------------+-----------+-----------------+------------+
 * | 3       | "Wetness"          | "Float"   | [0, 1]          | 1          |
 * +---------+--------------------+-----------+-----------------+------------+
 */
enum ProcessorVibratoParameter {
    Vibrato_Bypass,
    Vibrato_Rate_Hz,
    Vibrato_Depth_Semitone,
    Vibrato_Wetness,
    Vibrato_Max = Vibrato_Wetness,
};

/**
 * Name: "TimeDomainPitchShifter"
 * Parameters:
 * +---------+------------------------+------------+------------------------------------------------------------------------------+----------------+
 * | index   | name                   | type       | range                                                                        | default        |
 * +---------+------------------------+------------+------------------------------------------------------------------------------+----------------+
 * | 0       | "Bypass"               | "Bool"     | [false, true]                                                                | false          |
 * +---------+------------------------+------------+------------------------------------------------------------------------------+----------------+
 * | 1       | "Pitch Ratio"          | "Float"    | [0.25, 4]                                                                    | 1              |
 * +---------+------------------------+------------+------------------------------------------------------------------------------+----------------+
 * | 2       | "Interpolation Mode"   | "Choice"   | ["Linear", "Lagrange4", "Lagrange16", "Lagrange24", "Sinc32", "Lanczos32"]   | "Lagrange4"    |
 * +---------+------------------------+------------+------------------------------------------------------------------------------+----------------+
 * | 3       | "Mono Input"           | "Bool"     | [false, true]                                                                | true           |
 * +---------+------------------------+------------+------------------------------------------------------------------------------+----------------+
 * | 4       | "Mode"                 | "Choice"   | ["Fastest", "Moderate", "HighQuality", "UltraHighQuality"]                   | "Moderate"     |
 * +---------+------------------------+------------+------------------------------------------------------------------------------+----------------+
 */
enum ProcessorTimeDomainPitchShifterParameter {
    TimeDomainPitchShifter_Bypass,
    TimeDomainPitchShifter_Pitch_Ratio,
    TimeDomainPitchShifter_Interpolation_Mode,
    TimeDomainPitchShifter_Mono_Input,
    TimeDomainPitchShifter_Mode,
    TimeDomainPitchShifter_Max = TimeDomainPitchShifter_Mode,
};

#endif  //SAMI_CORE_SAMI_CORE_EFFECT_PARAM_H