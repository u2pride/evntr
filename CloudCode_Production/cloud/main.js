// ------- PRODUCTION ---------
// Evntr App - Parse Cloud Code
// Updated: August 2nd, 2015
// Developer:  Alex Ryan
// Release: v1.3

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
    },
    error: function(event, error) {
      console.error("Error Decrementing Picture Count " + error.code + " : " + error.message);
    }
  });
  
});

//Decrement Num Comments on Event after Comment Delete
Parse.Cloud.afterDelete("Comments", function(request) {
  Parse.Cloud.useMasterKey();
  
  var event = new Parse.Object("Events");
  event.id = request.object.get("commentEvent").id;
  event.increment("numComments", -1);
  event.save(null, {
    success: function(event) {
    },
    error: function(event, error) {
      console.error("Error Decrementing Comments Count " + error.code + " : " + error.message);
    }
  });
  
});

//Decrement Num Events on User after Event Delete
Parse.Cloud.afterDelete("Events", function(request) {
  Parse.Cloud.useMasterKey();
  
    console.log("loggggging " + request.object.get("parent"));
    
  var user = request.object.get("parent");
  user.increment("numEvents", -1);
  user.save(null, {
    success: function(user) {
    },
    error: function(user, error) {
      console.error("Error Decrementing Users Num Events Count " + error.code + " : " + error.message);
    }
  });
  
});



//Decrement Num Followers and Following Counts on Unfollow Activity
Parse.Cloud.afterDelete("Activities", function(request) {
  Parse.Cloud.useMasterKey();
  
  var followType = 1;
  
  if (request.object.get("type") == followType) {
           
       var userFollowed = new Parse.User;
       userFollowed.id = request.object.get("userTo").id;
       userFollowed.increment("numFollowers", -1);
       userFollowed.save(null, {
         success: function(event) {
         },
         error: function(event, error) {
          console.error("Error Decrementing Num Followers After Follow " + error.code + " : " + error.message);
         }
       });
       
       
       var userFollowing = new Parse.User;
       userFollowing.id = request.object.get("userFrom").id;
       userFollowing.increment("numFollowing", -1);
       userFollowing.save(null, {
         success: function(event) {
         },
         error: function(event, error) {
          console.error("Error Decrementing Num Following After Follow " + error.code + " : " + error.message);
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
         },
         error: function(event, error) {
          console.error("Error Decrementing Num Attenders on Event " + error.code + " : " + error.message);
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
                },
                error: function(myObject, error) {
                  console.error("Failed to delete attending activity after user revoked access to an event: " + error.code + " " + error.message); 
                }
             });  
          }
      },
      error: function(error) {
        console.error("Failed to Complete Query for Attending Activities Upon Revoke Access: " + error.code + " " + error.message);
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
    },
    error: function(event, error) {
      console.error("Error Incrementing Picture Count " + error.code + " : " + error.message);
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

          },
          error: function(activity, error) {
            console.error("Error saving comment activity " + error.code + " : " + error.message);
          }
        });
      }
      
    },
    error: function(myObject, error) {
      console.error("Error fetching event for comment " + error.code + " : " + error.message);
    }
    });
   
  
  //Increment Comments Count
  var event = new Parse.Object("Events");
  event.id = request.object.get("commentEvent").id;
  event.increment("numComments");
  event.save(null, {
    success: function(event) {
    },
    error: function(event, error) {
      console.error("Error Incrementing Comments Count " + error.code + " : " + error.message);
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
      },
      error: function(user, error) {
        console.error("Error Incrementing Num Events on User " + error.code + " : " + error.message);
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
           
       var userFollowed = new Parse.User;
       userFollowed.id = request.object.get("userTo").id;
       userFollowed.increment("numFollowers");
       userFollowed.save(null, {
         success: function(event) {
         },
         error: function(event, error) {
          console.error("Error Incrementing Num Followers After Follow " + error.code + " : " + error.message);
         }
       });
       
       
       var userFollowing = request.user;
       userFollowing.increment("numFollowing");
       userFollowing.save(null, {
         success: function(event) {
         },
         error: function(event, error) {
          console.error("Error Incrementing Num Following After Follow " + error.code + " : " + error.message);
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
         },
         error: function(event, error) {
          console.error("Error Incrementing Num Attenders on Event " + error.code + " : " + error.message);
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


//Background Jobs

Parse.Cloud.job("canonicalPrep", function(request, status) {
  Parse.Cloud.useMasterKey();
  
  // Query for all users
  var query = new Parse.Query(Parse.User);
  query.each(function(user) {
      
      var lowercaseUsername = user.get("username").toLowerCase();
      user.set("canonicalUsername", lowercaseUsername);

      return user.save();
  }).then(function() {
    status.success("Canonical update completed successfully.");
  }, function(error) {
    status.error("Uh oh, something went wrong.");
  });
});



//Before Save Hooks

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
    Parse.Cloud.useMasterKey();
    
    var lowercaseUsernameSubmitted = request.object.get("username").toLowerCase();
    
    var currentUser = request.object;
    
    if (!currentUser.get("numFollowers")) {
        currentUser.set("numFollowers", 0);
    }
    
    if (!currentUser.get("numFollowing")) {
        currentUser.set("numFollowing", 0);
    }
    
    if (!currentUser.get("numEvents")) {
        currentUser.set("numEvents", 0);
    }
    
    //If Username Field Has Been Updated
    if (request.object.dirty("username") && request.object.get("username").toLowerCase() != request.object.get("canonicalUsername")) {
        
        var query = new Parse.Query(Parse.User);
        query.equalTo("canonicalUsername", lowercaseUsernameSubmitted);
        query.first({
          success: function(user) {
            if (user) {

              response.error("Already taken.  Please choose another username.");
            
            } else {
              
              request.object.set("canonicalUsername", lowercaseUsernameSubmitted);
              response.success();

            }
          },
          error: function(error) {
            response.error("Please choose another username.");
          }  
      });
 
      } else {
        response.success();
      }
  
});


Parse.Cloud.afterSave("Reports", function(request, response) {
    Parse.Cloud.useMasterKey();
    
    var Mailgun = require('mailgun');
    Mailgun.initialize('sandbox4c4a9ed8e70f4100b14c2a3b9141c2a8.mailgun.org', 'key-3467e49ce851dd08391802eaf5e0e156');
    
    request.object.get('flaggedEvent').fetch ({
        success: function(eventFlagged) {
            // The object was retrieved successfully.
        
            request.object.get('userFrom').fetch ({
                success: function(userFrom) {

                
                    eventFlagged.get('parent').fetch ({
                        success: function(eventHost) {
                            
                            var message = "Type of Flag: " + request.object.get('flagType') + "\nMessage From User: " + request.object.get('flagDescription') + "\nFlagged Event Name: " + eventFlagged.get('title') + "\nEvent ObjectID: " + eventFlagged.id + "\nFlagged By User: " + userFrom.get('username') + "\nEvent Host: " + eventHost.get('username');
    
                            Mailgun.sendEmail({
                                to: "mfisher390@gmail.com",
                                from: "Evntr Reporting <postmaster@sandbox4c4a9ed8e70f4100b14c2a3b9141c2a8.mailgun.org>",
                                subject: "Evntr - New Report by User",
                                text: message
                            }, {
                                success: function(httpResponse) {
                                    console.log(httpResponse);
                                    //response.success("Email sent!");
                            },
                                error: function(httpResponse) {
                                console.error(httpResponse);
                                //response.error("Uh oh, something went wrong");
                                }
                            });
                        
                        },
                        error: function(object, error) {
                        }
                    });
                
                },
                error: function(object, error) {
                }
            });
        
    },
    error: function(object, error) {
        // The object was not retrieved successfully.
        // error is a Parse.Error with an error code and message.
    }
    });
    
});