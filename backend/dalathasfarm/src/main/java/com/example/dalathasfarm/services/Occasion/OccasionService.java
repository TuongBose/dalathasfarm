package com.example.dalathasfarm.services.Occasion;

import com.example.dalathasfarm.dtos.OccasionDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.Occasion;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.repositories.OccasionRepository;
import com.example.dalathasfarm.repositories.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.crossstore.ChangeSetPersister;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OccasionService implements IOccasionService{
    private final OccasionRepository occasionRepository;
    private final ProductRepository productRepository;

    @Override
    public Occasion getOccasionById(Integer id) throws Exception {
        return occasionRepository.findById(id)
                .orElseThrow(()->new DataNotFoundException("Occasion not found"));
    }

    @Override
    public List<Occasion> getAllOccasion() {
        return occasionRepository.findAll();
    }

    @Override
    public Occasion deleteOccasion(Integer id) throws Exception {
        Occasion occasion = occasionRepository.findById(id)
                .orElseThrow(() -> new ChangeSetPersister.NotFoundException());

        List<Product> products = productRepository.findByOccasion(occasion);
        if (!products.isEmpty()) {
            throw new IllegalStateException("Cannot delete occasion with associated products");
        } else {
            occasionRepository.deleteById(id);
            return occasion;
        }
    }

    @Override
    public Occasion updateOccasion(Integer id, OccasionDto occasionDto) throws Exception {
        Occasion existingOccasion = getOccasionById(id);
        if(!occasionRepository.existsByName(occasionDto.getName())) {
            existingOccasion.setName(occasionDto.getName());
            occasionRepository.save(existingOccasion);
            return existingOccasion;
        }else {
            throw new Exception("Occasion already exist");
        }
    }

    @Override
    public Occasion createOccasion(OccasionDto occasionDto) throws Exception {
        if(!occasionRepository.existsByName(occasionDto.getName())) {
            Occasion newOccasion = Occasion
                    .builder()
                    .name(occasionDto.getName())
                    .build();
            return occasionRepository.save(newOccasion);
        }
        else {
            throw new Exception("Occasion already exist");
        }
    }

    @Override
    public List<Occasion> getActiveOccasionsForToday() {
        LocalDate today = LocalDate.now();
        return occasionRepository.findActiveOccasionsForToday(today);
    }
}
