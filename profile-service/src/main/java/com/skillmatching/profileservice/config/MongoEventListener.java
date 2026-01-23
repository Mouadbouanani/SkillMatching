package com.skillmatching.profileservice.config;

import com.skillmatching.profileservice.entity.Profile;
import org.springframework.data.mongodb.core.mapping.event.AbstractMongoEventListener;
import org.springframework.data.mongodb.core.mapping.event.BeforeConvertEvent;
import org.springframework.stereotype.Component;

@Component
public class MongoEventListener extends AbstractMongoEventListener<Profile> {

    @Override
    public void onBeforeConvert(BeforeConvertEvent<Profile> event) {
        Profile profile = event.getSource();
        if (profile.getId() == null) {
            // New document - call prePersist
            profile.prePersist();
        } else {
            // Existing document - call preUpdate
            profile.preUpdate();
        }
        super.onBeforeConvert(event);
    }
}

