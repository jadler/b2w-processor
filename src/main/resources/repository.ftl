<#if package?? && package != "">
package ${package};

</#if>
import ${import};
import  org.springframework.data.mongodb.repository.MongoRepository;

public interface ${outClass} extends MongoRepository<${inClass}, String> {
}