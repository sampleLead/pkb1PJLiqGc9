/**
 * Triggers
 * <p>
 * This is a template that can be used against any object in Salesforce and
 * provides an easy to use mechanism to register a list of events to execute in
 * the correct context of a trigger. 
 **/
public class Triggers {

  /**
   * Evnt
   * <p>
   * An enum with an entry representing each Salesforce trigger event type.
   **/
  public enum Evnt {
  	beforeinsert,
  	beforeupdate,
  	beforedelete,
  	afterinsert,
  	afterupdate,
  	afterdelete,
  	afterundelete
  }

  /**
   * Handler
   * <p>
   * A handler to implement on any event. It doe not require or enfore any
   * pattern except the method name 'run()'. All apex classes and context
   * variables are accessible.
   **/
  public interface Handler {
  	void run();
  }
  
  // map of all event to be executed
  private map<String, list<Handler>> event_handler_map =
    new map<String,list<Handler>>();
   
  /**
   * bind
   *
   * @param event - the type of event to run against
   * @param eh    - the event handler to register to run
   *
   * This provides the mechanism to register an event to handled and run in the
   * context of the required event type.
   **/ 
  public Triggers bind(Evnt event, Handler eh)
  {
  	list<Handler> handlers = event_handler_map.get(event.name());
  	if (handlers == null) {
  		handlers = new list<Handler>();
  		event_handler_map.put(event.name(), handlers);
  	}
  	handlers.add(eh);
  	return this;
  }
    
  /**
   * getEventType
   *
   * This will return representing the type of event that initiated this trigger.
   **/
  private Evnt getEventType()
  {
  	Evnt event = null;
    
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        event = Evnt.beforeinsert;
      } else if (Trigger.isUpdate) {
        event = Evnt.beforeupdate;
      } else if (Trigger.isDelete) {
        event = Evnt.beforedelete;
      }
    } else if (Trigger.isAfter) {
      if (Trigger.isInsert) {
        event = Evnt.afterinsert;
      } else if (Trigger.isUpdate) {
        event = Evnt.afterupdate;
      } else if (Trigger.isDelete) {
        event = Evnt.afterdelete;
      } else if (Trigger.isUndelete) {
        event = Evnt.afterundelete;
      }
    }
    
  	return event;
  }
    
  /**
   * execute
   *
   * Runs the handlers that have been registered in the calling trigger.
   **/
  public void execute()
  {
  	Evnt event = getEventType();
  	
  	// if the event type could not be evaluated do not go any futher
  	if (event == null) { return; }
  	
  	// get the list of handlers and if an event has been bound then execute it
  	list<Handler> handlers = event_handler_map.get(event.name());
  	if ((handlers != null) && (!handlers.isEmpty())) {
  		for (Handler h: handlers) {
  			h.run();
  		}
  	}
  }
    
}