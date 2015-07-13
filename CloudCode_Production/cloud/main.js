// ------- PRODUCTION ---------
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
    
    console.log("UserMajor: " + currentMajor + "UserMinor: " + currentMinor);
    
    if (currentMajor > minMajor) {
      
      console.log("Accepted");
      response.success("true");
     
    } else if (currentMajor == minMajor) {
      
      if (currentMinor >= minMinor) {
        
        console.log("Accepted");
        response.success("true");
        
      } else {
        
        console.log("Rejected");
        response.success("false");
        
      }
    
    } else {
      
      console.log("Rejected");
      response.success("false");
      
    }
    
    }, function(error) {
        console.log("Error");
        response.error("Failed to retrieve config");
    });

});




//After Delete Hooks
//Decrement Num Pictures on Event after Piture Delete
Parse.Cloud.afterDelete("Pictures", function(request) {
  Parse.Cloud.useMasterKey();
  
  var query = new Parse.Query("Events");
  query.get(request.object.get("eventParent").id, {
    success: function(event) {
      event.increment("numPictures", -1);
      event.save();
    },
    error: function(error) {
      console.error("Error Decrementing Pictures Count " + error.code + " : " + error.message);
    }
  });
});

//Decrement Num Followers and Following Counts on Unfollow Activity
Parse.Cloud.afterDelete("Activities", function(request) {
  Parse.Cloud.useMasterKey();
  
  var followType = 1;
  
  if (request.object.get("type") == followType) {
           
       var queryFollowers = new Parse.Query("User");
       queryFollowers.get(request.object.get("userTo").id, {
         success: function(userOne) {
           userOne.increment("numFollowers", -1);
           userOne.save();
         },
         error: function(error) {
           console.error("Error Decrementing Num Followers Count " + error.code + " : " + error.message);
         }
       });
       
       var queryFollowing = new Parse.Query("User");
       queryFollowing.get(request.object.get("userFrom").id, {
         success: function(userTwo) {
           userTwo.increment("numFollowing", -1);
           userTwo.save();
         },
         error: function(error) {
           console.error("Error Decrementing Num Following Count " + error.code + " : " + error.message);
         }
       });
       
  }
  
  //Decrement Num Attenders on Event Upon Un-RSVP
  var attendingType = 4;
  
  if (request.object.get("type") == attendingType) {
     var queryAttending = new Parse.Query("Events");
     queryAttending.get(request.object.get("activityContent").id, {
       success: function(event) {
         event.increment("numAttenders", -1);
         event.save();
       },
       error: function(error) {
         console.error("Error Decrementing Num Attenders Count " + error.code + " : " + error.message);
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
  
  var query = new Parse.Query("Events");
  query.get(request.object.get("eventParent").id, {
    success: function(event) {
      event.increment("numPictures");
      event.save();
    },
    error: function(error) {
      console.error("Got an error " + error.code + " : " + error.message);
    }
  });
});

//Incrementing Comments Count on Event
Parse.Cloud.afterSave("Comments", function(request) {
  Parse.Cloud.useMasterKey();

  var query = new Parse.Query("Events");
  query.get(request.object.get("commentEvent").id, {
    success: function(event) {
      event.increment("numComments");
      event.save();
    },
    error: function(error) {
      console.error("Got an error " + error.code + " : " + error.message);
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
  
    var query = new Parse.Query("User");
    query.get(request.object.get("parent").id, {
      success: function(user) {
        user.increment("numEvents");
        user.save();
      },
      error: function(error) {
        console.error("Got an error " + error.code + " : " + error.message);
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
           
       var queryFollowers = new Parse.Query("User");
       queryFollowers.get(request.object.get("userTo").id, {
         success: function(userOne) {
           userOne.increment("numFollowers");
           userOne.save();
         },
         error: function(error) {
           console.error("Got an error " + error.code + " : " + error.message);
         }
       });
       
       var queryFollowing = new Parse.Query("User");
       queryFollowing.get(request.object.get("userFrom").id, {
         success: function(userTwo) {
           userTwo.increment("numFollowing");
           userTwo.save();
         },
         error: function(error) {
           console.error("Got an error " + error.code + " : " + error.message);
         }
       });
       
  }
  
  var attendingType = 4;
  
  if (request.object.get("type") == attendingType) {
     var queryAttending = new Parse.Query("Events");
     queryAttending.get(request.object.get("activityContent").id, {
       success: function(event) {
         event.increment("numAttenders");
         event.save();
       },
       error: function(error) {
         console.error("Got an error " + error.code + " : " + error.message);
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