// ------- DEVELOPMENT ---------
// Evntr App - Parse Cloud Code
// Updated: June 16th, 2015
// Developer:  Alex Ryan

//Custom Cloud Functions 

Parse.Cloud.define("checkVersion", function(request, response) {

  Parse.Config.get().then(function(config) {

    var minMajor = config.get("minMajorVersionNumber");
    var minMinor = config.get("minMinorVersionNumber");
    
    var currentMajor = parseInt(request.params.majorVersion);
    var currentMinor = parseInt(request.params.minorVersion);
    
    if (currentMajor > minMajor) {
      
      response.success("true");
     
    } else if (currentMajor == minMajor) {
      
      if (currentMinor >= minMinor) {
        
        response.success("true");
        
      } else {
        
        response.success("false");
        
      }
    
    } else {
      
      response.success("false");
      
    }
    
    }, function(error) {
      
        response.error("Failed to retrieve config");
    });

});




//After Delete Hooks
//Decrement Num Pictures on Event after Piture Delete
Parse.Cloud.afterDelete("Pictures", function(request) {
  Parse.Cloud.useMasterKey();
  
  var event = new Parse.Object("Events");
  event.id = request.object.get("eventParent").id;
  event.increment("numPictures", -1);
  event.save(null, {
    success: function(event) {
      // REMOVE
      console.log("Pictures Successfully Decremented.");
    },
    error: function(event, error) {
      console.log("Error Decrementing Picture Count " + error.code + " : " + error.message);
    }
  });
  
});

//Decrement Num Followers and Following Counts on Unfollow Activity
Parse.Cloud.afterDelete("Activities", function(request) {
  Parse.Cloud.useMasterKey();
  
  var followType = 1;
  
  if (request.object.get("type") == followType) {
           
       var userFollowed = new Parse.User; //TODO
       userFollowed.id = request.object.get("userTo").id;
       userFollowed.increment("numFollowers", -1);
       userFollowed.save(null, {
         success: function(event) {
          // REMOVE
          console.log("Num Followers After Follow Successfully Decremented.");
         },
         error: function(event, error) {
          console.log("Error Decrementing Num Followers After Follow " + error.code + " : " + error.message);
         }
       });
       
       
       var userFollowing = request.user;
       userFollowing.increment("numFollowing", -1);
       userFollowing.save(null, {
         success: function(event) {
          // REMOVE
          console.log("Num Following After Follow Successfully Decremented.");
         },
         error: function(event, error) {
          console.log("Error Decrementing Num Following After Follow " + error.code + " : " + error.message);
         }
       });
       
  }
  
  //Decrement Num Attenders on Event Upon Un-RSVP
  var attendingType = 4;
  
  if (request.object.get("type") == attendingType) {
     
      var event = new Parse.Object("Events");
      event.id = request.object.get("activityContent").id;
      event.increment("numAttenders", -1);
      event.save(null, {
         success: function(event) {
          // REMOVE
          console.log("Num Attenders on Event Successfully Decremented.");
         },
         error: function(event, error) {
          console.log("Error Decrementing Num Attenders on Event " + error.code + " : " + error.message);
         }
       });
      
  }
  
  //Delete Attending Activity Upon Revoke Access
  var grantedType = 5;
    
  if (request.object.get("type") == grantedType) {
    
      var Notification = Parse.Object.extend("Activities");
      var query = new Parse.Query(Notification);

      query.equalTo("userTo", request.object.get("userTo"));
      query.equalTo("type", attendingType);
      query.equalTo("activityContent", request.object.get("activityContent"));

      query.find({
        success: function(results) {

          for (var i = 0; i < results.length; i++) { 
            var object = results[i];
	
	           object.destroy({
                success: function(myObject) {
                  console.log("Deleted Attending Activity - Revoked Access");
                  },
                error: function(myObject, error) {

                  alert("Failed to delete attending activity after user revoked access to an event: " + error.code + " " + error.message);
                }
             });  
          }
      },
      error: function(error) {
        alert("Failed to Complete Query for Attending Activities Upon Revoke Access: " + error.code + " " + error.message);
      }
      });
    
  }
  
  
});

// After Save Hooks

//Incrementing Pictures Count on Event
Parse.Cloud.afterSave("Pictures", function(request) {
  Parse.Cloud.useMasterKey();
  
  var event = new Parse.Object("Events");
  event.id = request.object.get("eventParent").id;
  event.increment("numPictures");
  event.save(null, {
    success: function(event) {
      // REMOVE
      console.log("Pictures Successfully Incremented.");
    },
    error: function(event, error) {
      console.log("Error Incrementing Picture Count " + error.code + " : " + error.message);
    }
  });
 
});

//Incrementing Comments Count on Event
Parse.Cloud.afterSave("Comments", function(request) {
  Parse.Cloud.useMasterKey();
  
  //Create Activity for New Comment
  var Notification = Parse.Object.extend("Activities");
  var activity = new Notification();
  
  var commentType = 6;
  
  var eventForComment = request.object.get("commentEvent");
  eventForComment.fetch({
    success: function(event) {
      var eventParent = event.get("parent");
    
      if (eventParent.id != request.user.id) {
        
        activity.set("userTo", eventParent);
        activity.set("userFrom", request.user);
        activity.set("type", commentType);
        activity.set("activityContent", request.object.get("commentEvent"));
  
        activity.save(null, {
          success: function(activity) {
          console.log("Successfully saved comment activity");
        },
        error: function(activity, error) {
          console.log("Error saving comment activity " + error.code + " : " + error.message);
        }
        });
      }
      
    },
    error: function(myObject, error) {
      console.log("Error fetching event for comment " + error.code + " : " + error.message);
    }
    });
   
  
  //Increment Comments Count
  var event = new Parse.Object("Events");
  event.id = request.object.get("commentEvent").id;
  event.increment("numComments");
  event.save(null, {
    success: function(event) {
      // REMOVE
      console.log("Comments Successfully Incremented.");
    },
    error: function(event, error) {
      console.log("Error Incrementing Comments Count " + error.code + " : " + error.message);
    }
  });

});



//Incrementing Events Count on User
Parse.Cloud.afterSave("Events", function(request) {
  Parse.Cloud.useMasterKey();
  
  var createdAt = request.object.createdAt;
  var updatedAt = request.object.updatedAt;
  
  createdAt.setMilliseconds(0);
  updatedAt.setMilliseconds(0);
  
  if (createdAt.getTime() == updatedAt.getTime()) {
    
    var user = request.user;
    user.increment("numEvents");
    user.save(null, {
      success: function(user) {
        //REMOVE
        console.log("Successfully incremented Num Events on User");
      },
      error: function(user, error) {
        console.log("Error Incrementing Num Events on User " + error.code + " : " + error.message);
      }
      
    });
  
  }
 
});

//Incrementing Attenders Count on Event
//Incrementing Followers & Following Count on Users
Parse.Cloud.afterSave("Activities", function(request) {
  Parse.Cloud.useMasterKey();
  
  var followType = 1;
  
  if (request.object.get("type") == followType) {
           
       var userFollowed = new Parse.User; //TODO
       userFollowed.id = request.object.get("userTo").id;
       userFollowed.increment("numFollowers");
       userFollowed.save(null, {
         success: function(event) {
          // REMOVE
          console.log("Num Followers After Follow Successfully Incremented.");
         },
         error: function(event, error) {
          console.log("Error Incrementing Num Followers After Follow " + error.code + " : " + error.message);
         }
       });
       
       
       var userFollowing = request.user;
       userFollowing.increment("numFollowing");
       userFollowing.save(null, {
         success: function(event) {
          // REMOVE
          console.log("Num Following After Follow Successfully Incremented.");
         },
         error: function(event, error) {
          console.log("Error Incrementing Num Following After Follow " + error.code + " : " + error.message);
         }
       });       
      
  }
  
  var attendingType = 4;
  
  if (request.object.get("type") == attendingType) {
 
      var event = new Parse.Object("Events");
      event.id = request.object.get("activityContent").id;
      event.increment("numAttenders");
      event.save(null, {
         success: function(event) {
          // REMOVE
          console.log("Num Attenders on Event Successfully Incremented.");
         },
         error: function(event, error) {
          console.log("Error Incrementing Num Attenders on Event " + error.code + " : " + error.message);
         }
       });  
 
  }
  
 
  //Granted Acess - Add an Attending Activity to auto bring the user into the event.
  var grantedType = 5;
  
  if (request.object.get("type") == grantedType) {
    
    var Notification = Parse.Object.extend("Activities");
    var activity = new Notification();

    activity.set("userTo", request.object.get("userTo"));
    activity.set("type", attendingType);
    activity.set("activityContent", request.object.get("activityContent"));

    activity.save(null, {
      success: function(savedActivity) {

      },
      error: function(savedActivity, error) {
        console.error("Got an error creating new attending Activity " + error.code + " : " + error.message);
      }
      });
  }
 
 
});


//Background Job

Parse.Cloud.job("canonicalPrep", function(request, status) {
  Parse.Cloud.useMasterKey();
  
  // Query for all users
  var query = new Parse.Query(Parse.User);
  query.each(function(user) {
      
      var lowercaseUsername = user.get("username").toLowerCase();
      user.set("canonicalUsername", lowercaseUsername);
      console.log("username completed - " + lowercaseUsername);

      return user.save();
  }).then(function() {
    status.success("Canonical update completed successfully.");
  }, function(error) {
    status.error("Uh oh, something went wrong.");
  });
});



//Before Save Hooks

/*
In a beforeSave handler, use isNew. isNew is a Backbone method originally designed for client code. All isNew does is check whether the object has an objectId. In a beforeSave handler, a new object will not have an id yet, so it will do what you want.

In an afterSave handler, use existed. Immediately after the first time an object is saved, existed will return false to indicate that the last server operation created the object. If the object is subsequently saved again, the object will have already existed on the server, so existed will return true from then on.
*/


Parse.Cloud.beforeSave(Parse.User, function(request, response) {
    Parse.Cloud.useMasterKey();
    
    var lowercaseUsernameSubmitted = request.object.get("username").toLowerCase();
    
    console.log("username being checked in beforeSave Handler - " + lowercaseUsernameSubmitted);
    
    //If Username Field Has Been Updated
    if (request.object.dirty("username") && request.object.get("username").toLowerCase() != request.object.get("canonicalUsername")) {
        console.log("username has been changed... run validation.");
        
        var query = new Parse.Query(Parse.User);
        query.equalTo("canonicalUsername", lowercaseUsernameSubmitted);
        query.first({
          success: function(user) {
            if (user) {
              console.log("username exists return error message")
              response.error("Already taken.  Please choose another username.");
            
            } else {
              console.log("username doesn't already exist, allow save");

              console.log("object username: " + request.object.get("username") + "object canonical: " + request.object.get("canonicalUsername"));
              
              //if (request.object.get("username") != request.object.get("canonicalUsername")) {
                console.log("Update the Canonical Username");
                request.object.set("canonicalUsername", lowercaseUsernameSubmitted);
                response.success();
              //}

            }
          },
          error: function(error) {
            console.log("ALERT - overall query error issues");
            response.error("Please choose a-nother username.");
          }  
      });
 
      } else {
        console.log("username not changed. return.")
        response.success();
      }
  
});


Parse.Cloud.afterSave(Parse.User, function(request, response) {
    
  if (request.object.dirty("username")) {
    console.log("username is dirty in afterSave");
  } else {
    console.log("username is clean in afterSave");
  }
  
  //var currentUser = request.object;
  
  //currentUser.set("canonicalUsername", currentUser.get("username").toLowerCase());
  //currentUser.save();
  
});