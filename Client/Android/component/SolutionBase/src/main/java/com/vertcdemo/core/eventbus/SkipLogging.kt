// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.eventbus

/**
 * Mark the event not print by SolutionEventBus Log when post
 */
@Target(AnnotationTarget.CLASS)
annotation class SkipLogging