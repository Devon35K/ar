package com.example.ar

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.camera.core.AspectRatio
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.google.mediapipe.tasks.vision.core.RunningMode
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import androidx.camera.core.ImageProxy

class MyCameraView(
    private val context: Context,
    messenger: BinaryMessenger,
    id: Int,
    creationParams: Map<String?, Any?>?,
    private val activity: FlutterActivity
) : PlatformView, GestureRecognizerHelper.GestureRecognizerListener, LifecycleEventObserver {

    private var constraintLayout = ConstraintLayout(context)
    private var viewFinder = PreviewView(context)
    private var overlayView: OverlayView = OverlayView(context, null)

    private var backgroundExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var cameraFacing = CameraSelector.LENS_FACING_BACK
    private var imageAnalyzer: ImageAnalysis? = null
    private var preview: Preview? = null
    private var camera: Camera? = null
    private var cameraProvider: ProcessCameraProvider? = null

    private lateinit var gestureRecognizerHelper: GestureRecognizerHelper

    private var delegate: Int = GestureRecognizerHelper.DELEGATE_GPU
    private var minHandDetectionConfidence: Float =
        GestureRecognizerHelper.DEFAULT_HAND_DETECTION_CONFIDENCE
    private var minHandTrackingConfidence: Float = GestureRecognizerHelper
        .DEFAULT_HAND_TRACKING_CONFIDENCE
    private var minHandPresenceConfidence: Float = GestureRecognizerHelper
        .DEFAULT_HAND_PRESENCE_CONFIDENCE

    private val methodChannel = MethodChannel(messenger, "cameraView_$id")

    init {
        val layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        constraintLayout.layoutParams = layoutParams

        val constraintSet = ConstraintSet()
        constraintSet.clone(constraintLayout)

        viewFinder.id = View.generateViewId()
        viewFinder.implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        constraintLayout.addView(viewFinder)
        constraintSet.constrainWidth(viewFinder.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.constrainHeight(viewFinder.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.connect(viewFinder.id, ConstraintSet.LEFT, ConstraintSet.PARENT_ID, ConstraintSet.LEFT)
        constraintSet.connect(viewFinder.id, ConstraintSet.RIGHT, ConstraintSet.PARENT_ID, ConstraintSet.RIGHT)
        constraintSet.connect(viewFinder.id, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP)
        constraintSet.connect(viewFinder.id, ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM)

        overlayView.id = View.generateViewId()
        constraintLayout.addView(overlayView)
        constraintSet.constrainWidth(overlayView.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.constrainHeight(overlayView.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.connect(overlayView.id, ConstraintSet.LEFT, ConstraintSet.PARENT_ID, ConstraintSet.LEFT)
        constraintSet.connect(overlayView.id, ConstraintSet.RIGHT, ConstraintSet.PARENT_ID, ConstraintSet.RIGHT)
        constraintSet.connect(overlayView.id, ConstraintSet.TOP, ConstraintSet.PARENT_ID, ConstraintSet.TOP)
        constraintSet.connect(overlayView.id, ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM)
        
        constraintLayout.bringChildToFront(overlayView)
        constraintSet.applyTo(constraintLayout)

        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "switchCamera") {
                switchCamera()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        backgroundExecutor.execute {
            gestureRecognizerHelper = GestureRecognizerHelper(
                context = context,
                runningMode = RunningMode.LIVE_STREAM,
                minHandDetectionConfidence = minHandDetectionConfidence,
                minHandTrackingConfidence = minHandTrackingConfidence,
                minHandPresenceConfidence = minHandPresenceConfidence,
                currentDelegate = delegate,
                gestureRecognizerListener = this
            )

            viewFinder.post {
                setUpCamera()
            }
        }
    }

    private fun switchCamera() {
        cameraFacing = if (cameraFacing == CameraSelector.LENS_FACING_FRONT) {
            CameraSelector.LENS_FACING_BACK
        } else {
            CameraSelector.LENS_FACING_FRONT
        }
        bindCameraUseCases()
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        backgroundExecutor.shutdown()
        backgroundExecutor.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS)
    }

    private fun setUpCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener(
            {
                cameraProvider = cameraProviderFuture.get()
                bindCameraUseCases()
            },
            ContextCompat.getMainExecutor(context)
        )
    }

    override fun getView(): View {
        return constraintLayout
    }

    private fun bindCameraUseCases() {
        val aspectRatioStrategy = AspectRatioStrategy(
            AspectRatio.RATIO_16_9, AspectRatioStrategy.FALLBACK_RULE_NONE
        )

        val resolutionSelector = ResolutionSelector.Builder()
            .setAspectRatioStrategy(aspectRatioStrategy)
            .build()

        val cameraProvider = cameraProvider
            ?: throw IllegalStateException("Camera initialization failed.")

        val cameraSelector = CameraSelector.Builder()
            .requireLensFacing(cameraFacing).build()

        preview = Preview.Builder()
            .setResolutionSelector(resolutionSelector)
            .setTargetRotation(viewFinder.display.rotation)
            .build()

        imageAnalyzer = ImageAnalysis.Builder()
            .setResolutionSelector(resolutionSelector)
            .setTargetRotation(viewFinder.display.rotation)
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .setOutputImageFormat(OUTPUT_IMAGE_FORMAT_RGBA_8888)
            .build()
            .also {
                it.setAnalyzer(backgroundExecutor) { image ->
                    recognizeHand(image)
                }
            }

        cameraProvider.unbindAll()

        try {
            camera = cameraProvider.bindToLifecycle(
                activity,
                cameraSelector,
                preview,
                imageAnalyzer
            )
            preview?.surfaceProvider = viewFinder.surfaceProvider
        } catch (exc: Exception) {
            Log.e("TAG", "Use case binding failed", exc)
        }
    }

    private fun recognizeHand(imageProxy: ImageProxy) {
        if (this::gestureRecognizerHelper.isInitialized) {
            gestureRecognizerHelper.recognizeLiveStream(
                imageProxy = imageProxy,
                isFrontCamera = cameraFacing == CameraSelector.LENS_FACING_FRONT
            )
        } else {
            imageProxy.close()
        }
    }

    override fun onError(error: String, errorCode: Int) {
        Log.e("MyCameraView", "Error: $error, Code: $errorCode")
    }

    override fun onResults(resultBundle: GestureRecognizerHelper.ResultBundle) {
        activity.runOnUiThread {
            if (resultBundle.results.isNotEmpty()) {
                overlayView.setResults(
                    resultBundle.results.first(),
                    resultBundle.inputImageHeight,
                    resultBundle.inputImageWidth,
                    RunningMode.LIVE_STREAM
                )
            } else {
                overlayView.clear()
            }
            overlayView.invalidate()
        }
    }

    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
        when (event) {
            Lifecycle.Event.ON_RESUME -> {
                backgroundExecutor.execute {
                    if (this::gestureRecognizerHelper.isInitialized && gestureRecognizerHelper.isClosed()) {
                        gestureRecognizerHelper.setupGestureRecognizer()
                    }
                }
            }
            Lifecycle.Event.ON_PAUSE -> {
                if (this::gestureRecognizerHelper.isInitialized) {
                    backgroundExecutor.execute { gestureRecognizerHelper.clearGestureRecognizer() }
                }
            }
            Lifecycle.Event.ON_DESTROY -> {
                backgroundExecutor.shutdown()
            }
            else -> {}
        }
    }
}
