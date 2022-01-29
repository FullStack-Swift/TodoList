import OpenCombine
import UIKit

public extension UIButton {
  var tapPublisher: AnyPublisher<Void, Never> {
    controlEventPublisher(for: .touchUpInside)
  }
}

public extension UIControl {
  func controlEventPublisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
    Publishers.ControlEvent(control: self, events: events)
      .eraseToAnyPublisher()
  }
}

public extension OpenCombine.Publishers {
  struct ControlEvent<Control: UIControl>: Publisher {
    public typealias Output = Void
    public typealias Failure = Never
    
    private let control: Control
    private let controlEvents: Control.Event
    
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
      
    }
    
    func cancel() {
      subscriber = nil
    }
    
    @objc private func handleEvent() {
      _ = subscriber?.receive()
    }
  }
}
