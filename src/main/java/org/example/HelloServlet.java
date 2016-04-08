// Reflecting the directory structure where the file lives
package org.example;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class HelloServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        PrintWriter out = response.getWriter(  );
        response.setContentType("text/html");

        String buildInfoFileLocation = HelloServlet.class.getClassLoader().getResource("build-info.txt").getPath();
        Path buildInfoPath = Paths.get(buildInfoFileLocation);
        String buildInfoContent = new String(Files.readAllBytes(buildInfoPath));
        out.println("<pre>");
        out.println("BUILD DETAILS:");
        out.println(buildInfoContent);
        out.println("</pre>");

        String deployInfoFileLocation = "/opt/apache-tomcat-7.0.68/webapps/deploy-info.txt";
        Path deployInfoPath = Paths.get(deployInfoFileLocation);
        String deployInfoContent = new String(Files.readAllBytes(deployInfoPath));
        out.println("<pre>");
        out.println("Deploy DETAILS:");
        out.println(deployInfoContent);
        out.println("</pre>");

        out.println("<img src='http://orig07.deviantart.net/763e/f/2008/366/a/0/homer_yahoo_by_danielgoettig.jpg'>");
    }
}
