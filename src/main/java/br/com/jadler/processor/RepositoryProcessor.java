package br.com.jadler.processor;

import com.google.auto.service.AutoService;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.Set;
import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.Processor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.TypeElement;
import javax.tools.JavaFileObject;

/**
 * Cria uma classe Repository para cada classe com a anotação
 * {@literal @}RepositoryProperty no mesmo pacote
 *
 * @since 1.0
 * @version 1.0
 * @author <a href="mailto:jaguar.adler@gmail.com">Jaguaraquem A. Reinaldo</a>
 */
@SupportedAnnotationTypes("br.com.jadler.annotation.RepositoryProperty")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
@AutoService(Processor.class)
public class RepositoryProcessor extends AbstractProcessor {

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment env) {

        annotations.forEach(a -> {
            env.getElementsAnnotatedWith(a).stream().forEach(e -> {
                write(e.toString());
            });
        });

        return true;
    }

    @SuppressWarnings("ConvertToTryWithResources")
    private void write(String name) {

        int lastIndexOf = name.lastIndexOf(".");
        String basename = name.substring(lastIndexOf + 1);
        String pkgname = name.replace("." + basename, "");
        pkgname = pkgname.substring(0, pkgname.lastIndexOf("."));
        pkgname = pkgname + ".repository";

        try {


            StringBuilder builder = new StringBuilder();
            builder.append(String.format("package %s;%n%n", pkgname))
                    .append(String.format("import %s;%n", name))
                    .append(String.format("import org.springframework.data.mongodb.repository.MongoRepository;%n%n"))
                    .append(String.format("public interface %sRepository extends MongoRepository<%s, String> {}%n", basename, basename));

            String source = String.format("%s.%sRepository", pkgname, basename);
            JavaFileObject file = processingEnv.getFiler().createSourceFile(source);
            Writer writer = new PrintWriter(file.openWriter());
            writer.write(builder.toString());
            writer.flush();
            writer.close();

        } catch (IOException ex) {
            System.err.println(ex.getMessage());
        }
    }
}
