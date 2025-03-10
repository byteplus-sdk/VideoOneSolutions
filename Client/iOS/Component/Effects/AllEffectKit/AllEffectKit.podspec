Pod::Spec.new do |spec|
  spec.name         = 'AllEffectKit'
  spec.version      = '1.0.0'
  spec.summary      = 'AllEffectKit'
  spec.description  = 'AllEffectKit ... '
  spec.homepage     = 'https://github.com/volcengine'
  spec.license      = { :type => 'Copyright', :text => 'Bytedance copyright' }
  spec.author       = { 'byteplus' => 'byteplus@byteplus.com' }
  spec.source       = { :path => './'}
  spec.ios.deployment_target = '11.0'
  spec.requires_arc = true
  spec.libraries = 'stdc++', 'z'
  spec.source_files = 'EffectBeautyComponent/**/*.{h,m,c,mm}'
#   be_effect_symbols = <<EOF
# -Wl,-u,_bef_effect_ai_get_version
# -Wl,-u,_bef_effect_ai_check_license
# -Wl,-u,_bef_effect_ai_check_license_buffer
# -Wl,-u,_bef_effect_ai_create
# -Wl,-u,_bef_effect_ai_destroy
# -Wl,-u,_bef_effect_ai_init
# -Wl,-u,_bef_effect_ai_use_pipeline_processor
# -Wl,-u,_bef_effect_ai_set_intensity
# -Wl,-u,_bef_effect_ai_set_color_filter_v2
# -Wl,-u,_bef_effect_ai_set_camera_device_position
# -Wl,-u,_bef_effect_ai_composer_set_nodes
# -Wl,-u,_bef_effect_ai_algorithm_texture
# -Wl,-u,_bef_effect_ai_process_texture
# -Wl,-u,_bef_effect_ai_composer_set_mode
# -Wl,-u,_bef_effect_ai_set_width_height
# -Wl,-u,_bef_effect_ai_composer_update_node
# -Wl,-u,_bef_effect_ai_matting_check_license
# -Wl,-u,_bef_effect_ai_portrait_matting_init_model
# -Wl,-u,_bef_effect_ai_portrait_matting_destroy
# -Wl,-u,_bef_effect_ai_portrait_matting_set_param
# -Wl,-u,_bef_effect_ai_portrait_matting_do_detect
# -Wl,-u,_bef_effect_ai_portrait_get_output_shape
# -Wl,-u,_bef_effect_ai_portrait_matting_create
# -Wl,-u,_bef_effect_ai_set_orientation
# -Wl,-u,_bef_effect_ai_get_face_detect_result
# -Wl,-u,_bef_effect_ai_get_license_wrapper_instance
# -Wl,-u,_bef_effect_ai_set_render_api
# -Wl,-u,_bef_effect_ai_use_builtin_sensor
# -Wl,-u,_bef_effect_ai_check_online_license
# -Wl,-u,_bef_effect_ai_set_effect
# -Wl,-u,_bef_effect_ai_composer_set_nodes_with_tags
# -Wl,-u,_bef_effect_ai_composer_append_nodes
# -Wl,-u,_bef_effect_ai_composer_append_nodes_with_tags
# -Wl,-u,_bef_effect_ai_composer_remove_nodes
# -Wl,-u,_bef_effect_ai_load_resource_with_timeout
# -Wl,-u,_bef_effect_ai_set_algorithm_force_detect
# -Wl,-u,_bef_effect_ai_process_touch
# -Wl,-u,_bef_effect_ai_process_gesture
# -Wl,-u,_bef_effect_add_log_to_local_func_with_key
# -Wl,-u,_bef_effect_remove_log_to_local_func_with_key
# -Wl,-u,_bef_effect_load_egl_library_with_func
# -Wl,-u,_bef_effect_load_glesv2_library_with_func
# -Wl,-u,_bef_effect_ai_face_detect_create
# -Wl,-u,_bef_effect_ai_face_detect_destroy
# -Wl,-u,_bef_effect_ai_face_detect_setparam
# -Wl,-u,_bef_effect_ai_face_detect
# -Wl,-u,_bef_effect_ai_face_check_license
# -Wl,-u,_bef_effect_ai_set_render_cache_texture_with_buffer
# EOF
#   spec.user_target_xcconfig = {
#     "OTHER_LDFLAGS"=> "#{be_effect_symbols.split("\n").map{|s| s.strip}.join(' ')}",
#     "STRIP_STYLE": "non-global"
#   }
  
  spec.default_subspecs = 'Common'
  
  spec.subspec 'Common' do |subspec|
    subspec.source_files = 'Common/*'
    subspec.public_header_files = 'Common/*.h'
    subspec.dependency 'ToolKit'
    spec.dependency 'EffectUIKit'
    spec.dependency 'EffectResources'
    # spec.dependency 'EffectSDK_iOS_TOB'
    spec.dependency 'BytedEffectSDK'
    spec.dependency 'SSZipArchive'
  end
  
  spec.subspec 'RTCEffectManager' do |subspec|
    subspec.source_files = 'RTCEffectManager/*'
    subspec.public_header_files = 'RTCEffectManager/*.h'
    subspec.dependency 'ToolKit/RTC'
    subspec.dependency 'AllEffectKit/Common'
  end
  
  spec.subspec 'LiveEffectManager' do |subspec|
    subspec.source_files = 'LiveEffectManager/*'
    subspec.public_header_files = 'LiveEffectManager/*.h'
    subspec.dependency 'AllEffectKit/Common'
    subspec.dependency 'TTSDK/LivePush-RTS'
  end
end
