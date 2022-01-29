import UIKit
import OpenCombine

public extension UITapGestureRecognizer {
  /// A publisher which emits when this Tap Gesture Recognizer is triggered
  var tapPublisher: AnyPublisher<UITapGestureRecognizer, Never> {
    gesturePublisher(for: self)
  }
}

private func gesturePublisher<Gesture: UIGestureRecognizer>(for gesture: Gesture) -> AnyPublisher<Gesture, Never> {
  return OpenCombine.Publishers.ControlTarget(control: gesture,
                                              addTargetAction: { gesture, target, action in
    gesture.addTarget(target, action: action)
  },
                                              removeTargetAction: { gesture, target, action in
    gesture?.removeTarget(target, action: action)
  })
    .subscribe(on: ImmediateScheduler.shared)
    .map { gesture }
    .eraseToAnyPublisher()
}

public extension OpenCombine.Publishers {

  struct ControlTarget<Control: AnyObject>: Publisher {
    public typealias Output = Void
    public typealias Failure = Never
    
    private let control: Control
    private let addTargetAction: (Control, AnyObject, Selector) -> Void
    private let removeTargetAction: (Control?, AnyObject, Selector) -> Void
    
    public init(control: Control,
                addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
                removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void) {
      self.control = control
      self.addTargetAction = addTargetAction
      self.removeTargetAction = removeTargetAction
    }
    
    public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
      let subscription = Subscription(subscriber: subscriber,
                                      control: control,
                                      addTargetAction: addTargetAction,
                                      removeTargetAction: removeTargetAction)
      
      subscriber.receive(subscription: subscription)
    }
  }
}

private extension OpenCombine.Publishers.ControlTarget {
  private final class Subscription<S: Subscriber, Control: AnyObject>: OpenCombine.Subscription where S.Input == Void {
    private var subscriber: S?
    weak private var control: Control?
    
    private let removeTargetAction: (Control?, AnyObject, Selector) -> Void
    private let action = #selector(handleAction)
    
    init(subscriber: S,
         control: Control,
         addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
         removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void) {
      self.subscriber = subscriber
      self.control = control
      self.removeTargetAction = removeTargetAction
      
      addTargetAction(control, self, action)
    }
    
    func request(_ demand: Subscribers.Demand) {
      // We don't care about the demand at this point.
      // As far as we're concerned - The control's target events are endless until it is deallocated.
    }
    
    func cancel() {
      subscriber = nil
      removeTargetAction(control, self, action)
    }
    
    @objc private func handleAction() {
      _ = subscriber?.receive()
    }
  }
}
