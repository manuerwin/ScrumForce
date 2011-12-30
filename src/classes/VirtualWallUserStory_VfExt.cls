public with sharing class VirtualWallUserStory_VfExt {

    public VirtualWallUserStory_VfExt() {}

    public StoryAndTasks oneStoryAndTasks {
        get {
            if (oneStoryAndTasks == null) {
                oneStoryAndTasks = new StoryAndTasks();
            }
            return oneStoryAndTasks;
        }
        set;
    }
}