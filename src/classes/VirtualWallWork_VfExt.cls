public with sharing class VirtualWallWork_VfExt {

    public VirtualWallWork_VfExt() {}

    public WorkAndTasks oneWorkAndTasks {
        get {
            if (oneWorkAndTasks == null) {
                oneWorkAndTasks = new WorkAndTasks();
            }
            return oneWorkAndTasks;
        }
        set;
    }
}