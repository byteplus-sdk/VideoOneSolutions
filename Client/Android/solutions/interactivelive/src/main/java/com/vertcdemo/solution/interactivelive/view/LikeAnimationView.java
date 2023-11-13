// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.view;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PathMeasure;
import android.graphics.PointF;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.DrawableRes;

import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.util.Animatorable;
import com.vertcdemo.solution.interactivelive.util.AnimatorableFactory;
import com.vertcdemo.solution.interactivelive.util.ViewUtils;

import java.util.LinkedList;
import java.util.Random;

public class LikeAnimationView extends View {

    private static final int PRESET_WIDTH = 110;
    private static final int PRESET_DISTANCE = 235;

    @DrawableRes
    private static final int[] likeIcons = new int[]{
            R.drawable.ic_live_like1,
            R.drawable.ic_live_like2,
            R.drawable.ic_live_like3,
            R.drawable.ic_live_like4,
            R.drawable.ic_live_like5,
    };


    private int heightBase = 0;
    private int distance;

    private final LinkedList<Animatorable> animators = new LinkedList<>();

    private int w = 0;
    private int h = 0;

    private final Bitmap[] mBitmaps;
    private final int mBitmapWidth;
    private final int mBitmapHeight;

    private final Paint mPaint;

    private final PathMeasure mPathMeasure;

    private final Matrix mMatrix;

    private final Random mRandom = new Random();

    private int randomIndex() {
        return mRandom.nextInt(mBitmaps.length);
    }

    public LikeAnimationView(Context context) {
        super(context);
    }


    public LikeAnimationView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public LikeAnimationView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public LikeAnimationView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    {
        mMatrix = new Matrix();

        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setStrokeWidth(2);
        mPaint.setColor(Color.RED);
        mPaint.setStyle(Paint.Style.STROKE);

        mPathMeasure = new PathMeasure();

        Resources resources = getResources();
        mBitmaps = new Bitmap[likeIcons.length];
        for (int i = 0; i < likeIcons.length; i++) {
            mBitmaps[i] = BitmapFactory.decodeResource(resources, likeIcons[i]);
        }

        mBitmapWidth = mBitmaps[0].getWidth();
        mBitmapHeight = mBitmaps[0].getHeight();

        heightBase = resources.getDimensionPixelOffset(R.dimen.like_base_height);
    }

    private Path generatePath() {
        Path path = new Path();
        int width = w <= 0 ? ViewUtils.dp2px(PRESET_WIDTH) : w;
        distance = distance <= 0 ? ViewUtils.dp2px(PRESET_DISTANCE) : distance;
        int halfWidth = mBitmapWidth / 2;
        PointF p0 = new PointF(mRandom.nextInt(width - halfWidth) + halfWidth, mRandom.nextInt(20));
        PointF p1 = new PointF(mRandom.nextInt(width - halfWidth) + halfWidth, mRandom.nextInt(distance) + 20);
        PointF p2 = new PointF(mRandom.nextInt(width - halfWidth) + halfWidth, mRandom.nextInt(distance) + 20);
        PointF p3 = new PointF(width * 2.F / 3, distance);
        path.moveTo(p0.x, p0.y);
        path.cubicTo(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
        return path;
    }

    final float[] pos = new float[2];

    @Override
    protected void onDraw(Canvas canvas) {
        for (Animatorable animator : animators) {
            Path path = animator.getPath();
//            canvas.drawPath(path, mPaint);
            mPathMeasure.setPath(path, false);
            mPathMeasure.getPosTan(distance * animator.getValue(), pos, null);

            float scale = animator.getScale();

            int halfBitmapWidth = mBitmapWidth / 2;
            int halfBitmapHeight = mBitmapHeight / 2;
            mMatrix.setScale(scale, scale, halfBitmapWidth, halfBitmapHeight);
            float left = pos[0] - halfBitmapWidth;
            float top = pos[1] - halfBitmapHeight;
            mMatrix.postTranslate(left > 0 ? left : 0, top);
            if (animator.isNeedRotate()) {
                mMatrix.preRotate(animator.getRotate());
            }
            mPaint.setAlpha(animator.getAlpha());
            canvas.drawBitmap(mBitmaps[animator.colorIndex], mMatrix, mPaint);
        }
    }


    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        this.w = w;
        this.h = h;
        this.distance = h - heightBase;
    }

    public void startAnimation() {
        Animatorable animatorable = createAnimator();
        animators.addFirst(animatorable);

        animatorable.setListener(mListener);
        animatorable.startAnimation();
    }

    private Animatorable createAnimator() {
        Animatorable animator = AnimatorableFactory.obtain();
        if (!animator.hasPath()) {
            Path path = generatePath();
            animator.setPath(path);
        }
        animator.setNeedRotate(mRandom.nextInt(100) < 20);
        if (animator.isNeedRotate()) {
            animator.setRotate(-30 + mRandom.nextInt(60));
        }
        animator.colorIndex = randomIndex();

        return animator;
    }

    private final Animatorable.UpdateListener mListener = new Animatorable.UpdateListener() {
        @Override
        public void onAnimationEnd(Animatorable animatorable) {
            animators.remove(animatorable);
            AnimatorableFactory.recycle(animatorable);
        }

        @Override
        public void onAnimationUpdate(Animatorable animatorable) {
            postInvalidate();
        }
    };
}

