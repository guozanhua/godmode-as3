//
// godmode

package godmode.selector {

import godmode.core.StatefulTask;
import godmode.core.Task;
import godmode.core.TaskContainer;

/**
 * A selector that updates all children, every update, until a condition is met.
 */
public class ParallelSelector extends StatefulTask
    implements TaskContainer
{
    public static const ALL_SUCCESS :int = 0;   // SUCCESS if all succeed. FAIL if any fail.
    public static const ANY_SUCCESS :int = 1;   // SUCCESS if any succeed. FAIL if all fail.
    public static const ALL_FAIL :int = 2;      // SUCCESS if all fail. FAIL if any succeed.
    public static const ANY_FAIL :int = 3;      // SUCCESS if any fail. FAIL if all succeed.
    public static const ALL_COMPLETE :int = 4;  // SUCCESS when all succeed or fail.
    public static const ANY_COMPLETE :int = 5;  // SUCCESS when any succeed or fail.
    
    public function ParallelSelector (name :String, type :int, tasks :Vector.<Task>) {
        super(name);
        _type = type;
        _children = tasks;
    }
    
    public function get children () :Vector.<Task> {
        return _children;
    }
    
    override public function get description () :String {
        return super.description + ":" + typeName(_type);
    }
    
    override protected function reset () :void {
        for each (var task :Task in _children) {
            task.deactivate();
        }
    }
    
    override protected function update (dt :Number) :int {
        var runningChildren :Boolean = false;
        for each (var child :Task in _children) {
            var childStatus :int = child.updateTask(dt);
            if (childStatus == SUCCESS) {
                if (_type == ANY_SUCCESS || _type == ANY_COMPLETE) {
                    return SUCCESS;
                } else if (_type == ALL_FAIL) {
                    return FAIL;
                }
                
            } else if (childStatus == FAIL) {
                if (_type == ANY_FAIL || _type == ANY_COMPLETE) {
                    return SUCCESS;
                } else if (_type == ALL_SUCCESS) {
                    return FAIL;
                }
                
            } else {
                runningChildren = true;
            }
        }
        
        return (runningChildren ? RUNNING : SUCCESS);
    }
    
    protected static function typeName (type :int) :String {
        switch (type) {
        case ALL_SUCCESS: return "ALL_SUCCESS";
        case ANY_SUCCESS: return "ANY_SUCCESS";
        case ALL_FAIL: return "ALL_FAIL";
        case ANY_FAIL: return "ANY_FAIL";
        case ALL_COMPLETE: return "ALL_COMPLETE";
        case ANY_COMPLETE: return "ANY_COMPLETE";
        }
        throw new Error("Unrecognized type " + type);
    }
    
    protected var _type :int;
    protected var _children :Vector.<Task>
}
}