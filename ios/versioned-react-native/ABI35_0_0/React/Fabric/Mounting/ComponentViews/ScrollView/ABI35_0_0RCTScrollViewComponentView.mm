/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI35_0_0RCTScrollViewComponentView.h"

#import <ReactABI35_0_0/ABI35_0_0RCTAssert.h>
#import <ReactABI35_0_0/components/scrollview/ScrollViewShadowNode.h>
#import <ReactABI35_0_0/components/scrollview/ScrollViewLocalData.h>
#import <ReactABI35_0_0/components/scrollview/ScrollViewProps.h>
#import <ReactABI35_0_0/components/scrollview/ScrollViewEventEmitter.h>
#import <ReactABI35_0_0/graphics/Geometry.h>

#import "ABI35_0_0RCTConversions.h"
#import "ABI35_0_0RCTEnhancedScrollView.h"

using namespace facebook::ReactABI35_0_0;

@interface ABI35_0_0RCTScrollViewComponentView () <UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat scrollEventThrottle;

@end

@implementation ABI35_0_0RCTScrollViewComponentView {
  ABI35_0_0RCTEnhancedScrollView *_Nonnull _scrollView;
  UIView *_Nonnull _contentView;
  SharedScrollViewLocalData _scrollViewLocalData;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const ScrollViewProps>();
    _props = defaultProps;

    _scrollView = [[ABI35_0_0RCTEnhancedScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delegate = self;
    _scrollView.delaysContentTouches = NO;
    _contentView = [[UIView alloc] initWithFrame:_scrollView.bounds];
    [_scrollView addSubview:_contentView];
    [self addSubview:_scrollView];
  }

  return self;
}

#pragma mark - ABI35_0_0RCTComponentViewProtocol

+ (ComponentHandle)componentHandle
{
  return ScrollViewShadowNode::Handle();
}

- (void)updateProps:(SharedProps)props oldProps:(SharedProps)oldProps
{
  const auto &oldScrollViewProps = *std::static_pointer_cast<const ScrollViewProps>(oldProps ?: _props);
  const auto &newScrollViewProps = *std::static_pointer_cast<const ScrollViewProps>(props);

  [super updateProps:props oldProps:oldProps];

#define REMAP_PROP(ReactABI35_0_0Name, localName, target) \
  if (oldScrollViewProps.ReactABI35_0_0Name != newScrollViewProps.ReactABI35_0_0Name) { \
    target.localName = newScrollViewProps.ReactABI35_0_0Name; \
  }

#define REMAP_VIEW_PROP(ReactABI35_0_0Name, localName) REMAP_PROP(ReactABI35_0_0Name, localName, self)
#define MAP_VIEW_PROP(name) REMAP_VIEW_PROP(name, name)
#define REMAP_SCROLL_VIEW_PROP(ReactABI35_0_0Name, localName) REMAP_PROP(ReactABI35_0_0Name, localName, _scrollView)
#define MAP_SCROLL_VIEW_PROP(name) REMAP_SCROLL_VIEW_PROP(name, name)

  // FIXME: Commented props are not supported yet.
  MAP_SCROLL_VIEW_PROP(alwaysBounceHorizontal);
  MAP_SCROLL_VIEW_PROP(alwaysBounceVertical);
  MAP_SCROLL_VIEW_PROP(bounces);
  MAP_SCROLL_VIEW_PROP(bouncesZoom);
  MAP_SCROLL_VIEW_PROP(canCancelContentTouches);
  MAP_SCROLL_VIEW_PROP(centerContent);
  //MAP_SCROLL_VIEW_PROP(automaticallyAdjustContentInsets);
  MAP_SCROLL_VIEW_PROP(decelerationRate);
  MAP_SCROLL_VIEW_PROP(directionalLockEnabled);
  //MAP_SCROLL_VIEW_PROP(indicatorStyle);
  //MAP_SCROLL_VIEW_PROP(keyboardDismissMode);
  MAP_SCROLL_VIEW_PROP(maximumZoomScale);
  MAP_SCROLL_VIEW_PROP(minimumZoomScale);
  MAP_SCROLL_VIEW_PROP(scrollEnabled);
  MAP_SCROLL_VIEW_PROP(pagingEnabled);
  MAP_SCROLL_VIEW_PROP(pinchGestureEnabled);
  MAP_SCROLL_VIEW_PROP(scrollsToTop);
  MAP_SCROLL_VIEW_PROP(showsHorizontalScrollIndicator);
  MAP_SCROLL_VIEW_PROP(showsVerticalScrollIndicator);
  MAP_VIEW_PROP(scrollEventThrottle);
  MAP_SCROLL_VIEW_PROP(zoomScale);
  //MAP_SCROLL_VIEW_PROP(contentInset);
  //MAP_SCROLL_VIEW_PROP(scrollIndicatorInsets);
  //MAP_SCROLL_VIEW_PROP(snapToInterval);
  //MAP_SCROLL_VIEW_PROP(snapToAlignment);
}

- (void)updateLocalData:(SharedLocalData)localData
           oldLocalData:(SharedLocalData)oldLocalData
{
  assert(std::dynamic_pointer_cast<const ScrollViewLocalData>(localData));
  _scrollViewLocalData = std::static_pointer_cast<const ScrollViewLocalData>(localData);
  CGSize contentSize = ABI35_0_0RCTCGSizeFromSize(_scrollViewLocalData->getContentSize());
  _contentView.frame = CGRect {CGPointZero, contentSize};
  _scrollView.contentSize = contentSize;
}

- (void)mountChildComponentView:(UIView<ABI35_0_0RCTComponentViewProtocol> *)childComponentView
                          index:(NSInteger)index
{
  [_contentView insertSubview:childComponentView atIndex:index];
}

- (void)unmountChildComponentView:(UIView<ABI35_0_0RCTComponentViewProtocol> *)childComponentView
                            index:(NSInteger)index
{
  ABI35_0_0RCTAssert(childComponentView.superview == _contentView, @"Attempt to unmount improperly mounted component view.");
  [childComponentView removeFromSuperview];
}

- (ScrollViewMetrics)_scrollViewMetrics
{
  ScrollViewMetrics metrics;
  metrics.contentSize = ABI35_0_0RCTSizeFromCGSize(_scrollView.contentSize);
  metrics.contentOffset = ABI35_0_0RCTPointFromCGPoint(_scrollView.contentOffset);
  metrics.contentInset = ABI35_0_0RCTEdgeInsetsFromUIEdgeInsets(_scrollView.contentInset);
  metrics.containerSize = ABI35_0_0RCTSizeFromCGSize(_scrollView.bounds.size);
  metrics.zoomScale = _scrollView.zoomScale;
  return metrics;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  std::static_pointer_cast<const ScrollViewEventEmitter>(_eventEmitter)->onScroll([self _scrollViewMetrics]);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
  std::static_pointer_cast<const ScrollViewEventEmitter>(_eventEmitter)->onScroll([self _scrollViewMetrics]);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  std::static_pointer_cast<const ScrollViewEventEmitter>(_eventEmitter)->onScrollBeginDrag([self _scrollViewMetrics]);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
  std::static_pointer_cast<const ScrollViewEventEmitter>(_eventEmitter)->onScrollEndDrag([self _scrollViewMetrics]);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
  std::static_pointer_cast<const ScrollViewEventEmitter>(_eventEmitter)->onMomentumScrollBegin([self _scrollViewMetrics]);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  std::static_pointer_cast<const ScrollViewEventEmitter>(_eventEmitter)->onMomentumScrollEnd([self _scrollViewMetrics]);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
  std::static_pointer_cast<const ScrollViewEventEmitter>(_eventEmitter)->onMomentumScrollEnd([self _scrollViewMetrics]);
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view
{
  std::static_pointer_cast<const ScrollViewEventEmitter>(_eventEmitter)->onScrollBeginDrag([self _scrollViewMetrics]);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
  std::static_pointer_cast<const ScrollViewEventEmitter>(_eventEmitter)->onScrollEndDrag([self _scrollViewMetrics]);
}

@end
