<#if package?? && package != "">
package ${package};

</#if>
import ${import};
import br.com.jadler.service.PlanetsService;
import io.swagger.annotations.ApiOperation;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URI;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Optional;
import javax.validation.Valid;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.data.domain.ExampleMatcher.GenericPropertyMatcher;
import org.springframework.data.domain.ExampleMatcher.StringMatcher;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@RestController
@RequestMapping("/${"${inClass}"?lower_case}")
@ApiOperation("Operations belonging to the ${"${inClass}"?lower_case} entity")
public class ${outClass} {

    @Autowired
    protected ${inClass}Service service;

    @ApiOperation("Retrieve all ${"${inClass}"?lower_case}")
    @GetMapping({"", "/"})
    public ResponseEntity<Iterable<${inClass}>> list() {
        Collection<Planets> collection = new ArrayList<>();
        service.findAll().forEach(collection::add);

        ResponseEntity response = ResponseEntity.notFound().build();

        if (!collection.isEmpty()) {
            response = ResponseEntity.ok().body(collection);
        }

        return response;
    }

    @ApiOperation("Insert a new ${"${inClass}"?lower_case} entity")
    @PostMapping({"/"})
    public ResponseEntity<${inClass}> create(@Valid @RequestBody ${inClass} c) {
        ${inClass} p = service.save(c);

        ResponseEntity response = ResponseEntity.notFound().build();

        if (p != null) {
            URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                    .path("/id/{id}")
                    .buildAndExpand(p.getId())
                    .toUri();

            response = ResponseEntity.created(location).body(p);
        }

        return response;
    }

    @ApiOperation("Update an ${"${inClass}"?lower_case} given its id")
    @PutMapping({"/id/{id}"})
    public ResponseEntity<${inClass}> modify(@PathVariable("id") String id, @Valid @RequestBody ${inClass} c) {
        ResponseEntity response = ResponseEntity.notFound().build();

        if (c.getId() != null && c.getId().equals(id)) {
            ${inClass} p = service.save(c);
            if (p != null) {
                response = ResponseEntity.ok(p);
            }
        }

        return response;
    }

    @ApiOperation("Delete an ${"${inClass}"?lower_case} given its id")
    @DeleteMapping({"/id/{id}"})
    public ResponseEntity<?> delete(@PathVariable String id) {
        if (service.findById(id).isPresent()) {
            service.deleteById(id);
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.notFound().build();
    }

<#if elements??>
<#list elements as element>
    @ApiOperation("Retrieve a ${"${inClass}"?lower_case} given its ${element.getSimpleName()}")
    @GetMapping(value = {"/${element.getSimpleName()}/{${element.getSimpleName()}}"})
    public ResponseEntity<${inClass}> getBy${"${element.getSimpleName()}"?capitalize}(@PathVariable("${element.getSimpleName()}") ${element.asType()} value) {

        ResponseEntity response = new ResponseEntity("${inClass} with ${element.getSimpleName()} '" + value + "' not found.", HttpStatus.NOT_FOUND);

        try {
            ${inClass} c = new ${inClass}();

            Method method = c.getClass().getDeclaredMethod("set${"${element.getSimpleName()}"?capitalize}", String.class);
            method.setAccessible(true);
            method.invoke(c, value);

            GenericPropertyMatcher property;
            property = GenericPropertyMatcher.of(StringMatcher.EXACT);

            ExampleMatcher matcher = ExampleMatcher.matching()
                    .withIgnoreCase()
                    .withMatcher("${element.getSimpleName()}", property);

            Optional<${inClass}> element = service.findOne(Example.of(c, matcher));
            if (element.isPresent()) {
                response = ResponseEntity.ok(element.get());
            }

        } catch (NoSuchMethodException | SecurityException | IllegalAccessException | IllegalArgumentException | InvocationTargetException ex) {
            LoggerFactory.getLogger(this.getClass()).error(ex.getLocalizedMessage());
        }

        return response;
    }

</#list>
</#if>
}