import OpenCombine
import UIKit

public extension UIButton {
  /// A publisher emitting tap events from this button.
  var tapPublisher: AnyPublisher<Void, Never> {
    controlEventPublisher(for: .touchUpInside)
  }
}

public extension UIControl {
  /// A publisher emitting events from this control.
  func controlEventPublisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
    Publishers.ControlEvent(control: self, events: events)
      .eraseToAnyPublisher()
  }
}

public extension OpenCombine.Publishers {
    /// A Control Event is a publisher that emits whenever the provided
    /// Control Events fire.
    struct ControlEvent<Control: UIControl>: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let control: Control
        private let controlEvents: Control.Event

        /// Initialize a publisher that emits a Void
        /// whenever any of the provided Control Events trigger.
        ///
        /// - parameter control: UI Control.
        /// - parameter events: Control Events.
        public init(control: Control,
                    events: Control.Event) {
            self.control = control
            self.controlEvents = events
        }

        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            control: control,
                                            event: controlEvents)

            subscriber.receive(subscription: subscription)
        }
    }
}


extension OpenCombine.Publishers.ControlEvent {
    private final class Subscription<S: Subscriber, Control: UIControl>: OpenCombine.Subscription where S.Input == Void {
        private var subscriber: S?
        weak private var control: Control?

        init(subscriber: S, control: Control, event: Control.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(handleEvent), for: event)
        }

        func request(_ demand: Subscribers.Demand) {
            // We don't care about the demand at this point.
            // As far as we're concerned - UIControl events are endless until the control is deallocated.
        }

        func cancel() {
            subscriber = nil
        }

        @objc private func handleEvent() {
            _ = subscriber?.receive()
        }
    }
}
