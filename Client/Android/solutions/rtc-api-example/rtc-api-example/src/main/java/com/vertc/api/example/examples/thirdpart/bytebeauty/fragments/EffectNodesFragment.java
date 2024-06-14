package com.vertc.api.example.examples.thirdpart.bytebeauty.fragments;

import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Pair;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;

import com.ss.bytertc.engine.data.VirtualBackgroundSource;
import com.ss.bytertc.engine.data.VirtualBackgroundSourceType;
import com.ss.bytertc.engine.video.IVideoEffect;
import com.vertc.api.example.R;
import com.vertc.api.example.databinding.LayoutEffectNodesBinding;
import com.vertc.api.example.examples.thirdpart.bytebeauty.ByteBeautyViewModel;
import com.vertc.api.example.examples.thirdpart.bytebeauty.EffectResourceManager;
import com.vertc.api.example.examples.thirdpart.bytebeauty.bean.EffectNode;
import com.vertc.api.example.examples.thirdpart.bytebeauty.bean.EffectSection;
import com.vertc.api.example.examples.thirdpart.bytebeauty.bean.EffectType;
import com.vertc.api.example.examples.thirdpart.bytebeauty.utils.BeautyData;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class EffectNodesFragment extends Fragment {
    private static final String TAG = "ByteBeauty";

    public static EffectNodesFragment newInstance(EffectSection section) {
        EffectNodesFragment fragment = new EffectNodesFragment();
        Bundle args = new Bundle();
        args.putSerializable("section", section);
        fragment.setArguments(args);

        return fragment;
    }

    public EffectNodesFragment() {
        super(R.layout.layout_effect_nodes);
    }

    private EffectNodesViewModel viewModel;
    private ByteBeautyViewModel parentViewModel;

    private EffectSection section;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle arguments = requireArguments();
        section = (EffectSection) arguments.getSerializable("section");
        assert section != null;

        parentViewModel = parentModelProvider().get(ByteBeautyViewModel.class);
        viewModel = parentModelProvider().get(String.valueOf(section), EffectNodesViewModel.class);

        List<EffectNode> nodes = viewModel.nodes.getValue();
        if (nodes == null) {
            List<EffectNode> values = BeautyData.getEffectNodes(section);

            for (EffectNode value : values) {
                if (value.selected) {
                    viewModel.current = value;
                    break;
                }
            }
            viewModel.nodes.setValue(values);
        }
    }


    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        LayoutEffectNodesBinding binding = LayoutEffectNodesBinding.bind(view);

        boolean hasProgress = section.hasProgress();
        if (hasProgress) {
            binding.valueGroup.setVisibility(View.VISIBLE);
            binding.valueTitle.setText(section.progressTitle);
            binding.valueSlider.addOnChangeListener((slider, value, fromUser) -> {
                if (!fromUser) {
                    return;
                }
                EffectNode node = Objects.requireNonNull(viewModel.current);
                if (node.type == EffectType.beauty) {
                    node.value = value;
                    applyBeautyValue(node.key, node.subKey, value);
                } else if (node.type == EffectType.filter) {
                    node.value = value;
                    applyFilterValue(node.key, value);
                } else {
                    Log.w(TAG, "[EffectNodesFragment] Unhandled Slider.OnChangeListener for type: " + node.type);
                }
            });
        } else {
            binding.valueGroup.setVisibility(View.GONE);
        }

        binding.recycler.setLayoutManager(new GridLayoutManager(getContext(), 4));
        binding.recycler.setItemAnimator(null);
        EffectNodeAdapter adapter = new EffectNodeAdapter(node -> {
            if (viewModel.current != null
                    && viewModel.current.selected
                    && TextUtils.equals(node.key, viewModel.current.key)) {
                if (node.type == EffectType.beauty || node.type == EffectType.filter) {
                    // No need to handle already selected  [beauty, filter] node
                    return;
                }
            }
            List<EffectNode> values = Objects.requireNonNull(viewModel.nodes.getValue());
            List<EffectNode> newValues = new ArrayList<>();

            for (EffectNode value : values) {
                if (value.selected && TextUtils.equals(value.key, node.key)) {
                    if (node.type == EffectType.sticker || node.type == EffectType.virtualBackground) {
                        // For Items that support unselect action
                        EffectNode current = value.copy(false);
                        viewModel.current = null;
                        newValues.add(current);

                        if (node.type == EffectType.sticker) {
                            applyStickerEffect(node.key, false);
                            parentViewModel.currentSticker.postValue(new Pair<>(section, null));
                        } else {
                            applyVirtualEffect(node.key, false);
                        }
                    } else {
                        newValues.add(value);
                    }
                } else if (value.selected && !TextUtils.equals(value.key, node.key)) {
                    if (node.type == EffectType.filter) {
                        // For Filter type we also need to the clear the unselected item's value
                        // Because filter's value conflict with each other;
                        newValues.add(value.copy(false, 0.f));
                    } else {
                        newValues.add(value.copy(false));
                    }
                } else if (!value.selected && TextUtils.equals(value.key, node.key)) {
                    // Current selected node
                    EffectNode selected = value.copy(true);
                    viewModel.current = selected;
                    newValues.add(selected);

                    if (node.type == EffectType.sticker) {
                        applyStickerEffect(node.key, true);
                        parentViewModel.currentSticker.postValue(new Pair<>(section, node.key));
                    } else if (node.type == EffectType.virtualBackground) {
                        applyVirtualEffect(node.key, true);
                    } else if (node.type == EffectType.filter) {
                        applyFilterValue(node.key, node.value);
                    }

                    if (hasProgress) {
                        // The item has value, need update the slider
                        binding.valueSlider.setValue(node.value);
                    }
                } else {
                    newValues.add(value);
                }
            }

            viewModel.nodes.postValue(newValues);
        });
        binding.recycler.setAdapter(adapter);

        viewModel.nodes.observe(getViewLifecycleOwner(), nodes -> {
            adapter.setList(Objects.requireNonNull(nodes));
        });

        parentViewModel.currentSticker.observe(getViewLifecycleOwner(), sticker -> {
            String stickerKey = sticker == null ? null : sticker.second;
            if (stickerKey == null) {
                // No need to handle unselected state, because of this can't effect current EffectSection
                return;
            }
            if (sticker.first == section) {
                // No need to handle my section Changes
                return;
            }
            List<EffectNode> nodes = viewModel.nodes.getValue();
            if (nodes == null) {
                return;
            }

            ArrayList<EffectNode> newNodes = new ArrayList<>();

            boolean updated = false;
            for (EffectNode node : nodes) {
                if (node.type != EffectType.sticker) {
                    // Only Stickers exist in Multi-Group
                    break;
                }
                if (node.selected && !TextUtils.equals(stickerKey, node.key)) {
                    // Another sticker in Other-Group is selected, need unselect this
                    newNodes.add(node.copy(false));
                    updated = true;
                } else {
                    newNodes.add(node);
                }
            }

            if (updated) {
                viewModel.nodes.postValue(newNodes);
            }
        });
    }

    void applyBeautyValue(String key, String subKey, float value) {
        IVideoEffect videoEffect = parentViewModel.requireVideoEffect();
        EffectResourceManager resourceManager = parentViewModel.requireResourceManager();
        if (TextUtils.equals(subKey, "beauty")) {
            int retValue = videoEffect.updateEffectNode(resourceManager.getBeautyPath(), key, value);
            Log.d(TAG, "[EffectNodesFragment][Beauty][beauty] updateEffectNode: " + retValue);
        } else if (TextUtils.equals(subKey, "reshape")) {
            int retValue = videoEffect.updateEffectNode(resourceManager.getReshapePath(), key, value);
            Log.d(TAG, "[EffectNodesFragment][Beauty][reshape] updateEffectNode: " + retValue);
        }
    }

    void applyFilterValue(String key, float value) {
        IVideoEffect videoEffect = parentViewModel.requireVideoEffect();
        EffectResourceManager resourceManager = parentViewModel.requireResourceManager();
        int retValue = videoEffect.setColorFilter(resourceManager.getFilterPathByName(key));
        Log.d(TAG, "[EffectNodesFragment][Filter] setColorFilter: " + retValue);
        retValue = videoEffect.setColorFilterIntensity(value);
        Log.d(TAG, "[EffectNodesFragment][Filter] setColorFilterIntensity: " + retValue);
    }

    void applyStickerEffect(String key, boolean selected) {
        IVideoEffect videoEffect = parentViewModel.requireVideoEffect();
        EffectResourceManager resourceManager = parentViewModel.requireResourceManager();

        List<String> pathList = resourceManager.basicEffectNodePaths();
        if (selected) {
            String path = resourceManager.getStickerPathByName(key);
            pathList.add(path);

            int index = path.indexOf("com.byteplus.videoone.android/files");
            if (index != -1) {
                // remove 'com.byteplus.videoone.android/'
                Log.d(TAG, "[EffectNodesFragment][Sticker] relative-path=" + path.substring(index + 30));
            } else {
                Log.d(TAG, "[EffectNodesFragment][Sticker] path=" + path);
            }
        }
        int retValue = videoEffect.setEffectNodes(pathList);
        Log.d(TAG, "[EffectNodesFragment][Sticker] setEffectNodes: " + retValue);
    }

    void applyVirtualEffect(String type, boolean selected) {
        IVideoEffect videoEffect = parentViewModel.requireVideoEffect();
        EffectResourceManager resourceManager = parentViewModel.requireResourceManager();

        if (selected) {
            VirtualBackgroundSource backgroundSource = new VirtualBackgroundSource();
            if (TextUtils.equals(type, "color")) {
                backgroundSource.sourceType = VirtualBackgroundSourceType.COLOR;
                backgroundSource.sourceColor = Color.parseColor("#1278ff");
            } else if (TextUtils.equals(type, "image")) {
                backgroundSource.sourceType = VirtualBackgroundSourceType.IMAGE;
                backgroundSource.sourcePath = resourceManager.getVirtualBackgroundResourcePath();
            } else {
                Log.w(TAG, "[EffectNodesFragment] Unknown virtual background type: " + type);
                return;
            }
            String portraitPath = resourceManager.getEffectPortraitPath();
            int retValue = videoEffect.enableVirtualBackground(portraitPath, backgroundSource);
            Log.d(TAG, "[EffectNodesFragment] enableVirtualBackground: " + retValue);
        } else {
            videoEffect.disableVirtualBackground();
        }
    }

    @NonNull
    private ViewModelProvider parentModelProvider() {
        Fragment parentFragment = getParentFragment();
        if (parentFragment != null) {
            return new ViewModelProvider(parentFragment);
        } else {
            return new ViewModelProvider(requireActivity());
        }
    }
}
