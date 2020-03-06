<#if package?? && package != "">
package ${package};

</#if>
import ${import};
import br.com.jadler.service.PlanetsService;
import io.swagger.annotations.ApiOperation;
import java.net.URI;
import java.util.Collection;
import java.util.Optional;
import javax.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.data.domain.ExampleMatcher.GenericPropertyMatcher;
import org.springframework.data.domain.ExampleMatcher.StringMatcher;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@RestController
@RequestMapping("/${"${inClass}"?lower_case}")
@ApiOperation("Operations belonging to the ${"${inClass}"?lower_case} entity")
public class ${outClass} {

    @Autowired
    protected ${inClass}Service service;

    @ApiOperation("Retrieve all ${"${inClass}"?lower_case}")
    @GetMapping({"", "/"})
    public ResponseEntity<Collection<${inClass}>> list() {
        Collection<${inClass}> collection = repository.findAll();

        if (!collection.isEmpty()) {
            return ResponseEntity.ok().body(collection);
        }

        return ResponseEntity.notFound().build();
    }

    @ApiOperation("Insert a new ${"${inClass}"?lower_case} entity")
    @PostMapping({"/"})
    public ResponseEntity<${inClass}> create(@Valid @RequestBody ${inClass} c) {
        ${inClass} p = repository.save(c);
        if (p != null) {

            URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                    .path("/id/{id}")
                    .buildAndExpand(p.getId())
                    .toUri();

            return ResponseEntity.created(location).body(p);
        }

        return ResponseEntity.notFound().build();
    }

    @ApiOperation("Update an ${"${inClass}"?lower_case} given its id")
    @PutMapping({"/id/{id}"})
    public ResponseEntity<${inClass}> modify(@PathVariable("id") String id, @Valid @RequestBody ${inClass} c) {
        if (c.getId() == null || !c.getId().equals(id)) {
            return ResponseEntity.notFound().build();
        }

        Planets p = repository.save(c);
        if (p != null) {
            return ResponseEntity.ok(p);
        }

        return ResponseEntity.notFound().build();
    }

    @ApiOperation("Delete an ${"${inClass}"?lower_case} given its id")
    @DeleteMapping({"/id/{id}"})
    public ResponseEntity<?> delete(@PathVariable String id) {
        if (repository.findById(id).isPresent()) {
            repository.deleteById(id);
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.notFound().build();
    }

<#if elements??>
<#list elements as element>
    @ApiOperation("Retrieve a ${"${inClass}"?lower_case} given its ${element.getSimpleName()}")
    @GetMapping(value = {"/${element.getSimpleName()}/{${element.getSimpleName()}}"})
    public ResponseEntity<${inClass}> getBy${"${element.getSimpleName()}"?capitalize}(@PathVariable("${element.getSimpleName()}") ${element.asType()} value) {
        ${inClass} c = new ${inClass}();
        c.set${"${element.getSimpleName()}"?capitalize}(value);
        
        GenericPropertyMatcher property;
        property = GenericPropertyMatcher.of(StringMatcher.EXACT);

        ExampleMatcher matcher = ExampleMatcher.matching()
                .withIgnoreCase()
                .withMatcher("${element.getSimpleName()}", property);

        Optional<${inClass}> element = repository.findOne(Example.of(c, matcher));
        if (element.isPresent()) {
            return ResponseEntity.ok(element.get());
        }
        
        return new ResponseEntity("${inClass} with ${element.getSimpleName()} " + value + " not found.", HttpStatus.NOT_FOUND);
    }

</#list>
</#if>
}