package com.example.dalathasfarm.services.Occasion;

import com.example.dalathasfarm.dtos.OccasionDto;
import com.example.dalathasfarm.models.Occasion;

import java.util.List;

public interface IOccasionService {
    Occasion getOccasionById(Integer id) throws  Exception;
    List<Occasion> getAllOccasion();
    Occasion deleteOccasion(Integer id) throws  Exception;
    Occasion updateOccasion(Integer id, OccasionDto occasionDto) throws  Exception;
    Occasion createOccasion(OccasionDto occasionDto) throws  Exception;
}
