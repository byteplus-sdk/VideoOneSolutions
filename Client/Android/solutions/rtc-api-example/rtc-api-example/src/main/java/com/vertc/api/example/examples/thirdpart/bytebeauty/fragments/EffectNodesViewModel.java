package com.vertc.api.example.examples.thirdpart.bytebeauty.fragments;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertc.api.example.examples.thirdpart.bytebeauty.bean.EffectNode;

import java.util.List;

public class EffectNodesViewModel extends ViewModel {
    MutableLiveData<List<EffectNode>> nodes = new MutableLiveData<>(null);

    EffectNode current;
}
